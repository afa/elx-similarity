defmodule Similarity.Strategy.Ranking.TfIdf do
  @moduledoc """
  build ranks for document, calculating ranks with it for corpus
  limited only by model
  """

  import Ecto.Query
  require Result
  require Math
  alias App.Repo

  def call(doc_id) do
    with {:ok, doc} <- load_doc(doc_id),
         {:ok, model} <- load_model(doc),
         {:ok, docs} <- load_rankable(doc),
         {:ok, keys} <- load_doc_tokens(doc),
         {:ok, total} <- count_docs(model)
    do
      Enum.map(docs, &rank(model, doc, keys, total, &1))
      |> Result.fold
    else
      {:error, res} ->
        {:error, res}
    end
  end

  defp load_doc(doc_id) do
    Repo.get(Similarity.Document, doc_id)
    |> Result.ok
  end

  defp load_rankable(doc) do
    from(d in Similarity.Document,
      where: d.model_id == ^doc.model_id and d.id != ^doc.id,
      select: [:id]
    )
    |> Repo.all
    |> Result.ok
  end

  defp load_model(doc) do
    from(m in Similarity.Model,
      where: m.id == ^doc.model_id
    )
    |> Repo.one
    |> Result.ok
  end

  defp load_doc_tokens(doc) do
    from(c in Similarity.TokenCount,
      where: c.document_id == ^doc.id,
      join: t in Similarity.Token,
      on: t.id == c.token_id,
      select: [c.count, t.value]
    )
    |> Repo.all
    |> Enum.reduce(%{}, fn [cnt, val], map -> Map.put(map, val, cnt) end)
    |> Result.ok
  end

  defp rank(model, doc, doc_counts, total, to_rank) do
    with {:ok, rank_counts} <- load_doc_tokens(to_rank),
         # counts <- Map.merge(doc_counts, rank_counts),
         keys <- Enum.concat(Map.keys(doc_counts), Map.keys(rank_counts))
         |> Enum.uniq
         |> Enum.sort(:asc),
         {:ok, my_idf} <- calc_idf(total, keys, doc_counts),
         {:ok, my_tf} <- calc_tf(keys, doc_counts),
         {:ok, my_tfidf} <- calc_tfidf(my_tf, my_idf),
         {:ok, idf} <- calc_idf(total, keys, rank_counts),
         {:ok, tf} <- calc_tf(keys, rank_counts),
         {:ok, tfidf} <- calc_tfidf(tf, idf),
         {:ok, val} <- cos(my_tfidf, tfidf)
    do
      {doc.id, to_rank.id, val}
      |> Result.ok
    else
      {:error, err} ->
        {:error, err}
    end
  end

  defp calc_idf(total, keys, counts) do
    Enum.map(keys, fn key -> 1.0 + Math.log(total / (1 + Map.get(counts, key, 0))) end)
    |> Result.ok
  end

  defp calc_tf(keys, counts) do
    # вектор: количество токенов на текст деленное на сумму количеств токенов на текст
    total = Enum.reduce(counts, 0, fn {_, v}, acc -> acc + v end)
    Enum.map(keys, fn k -> Map.get(counts, k, 0) / total end)
    |> Result.ok
  end

  defp calc_tfidf(tf, idf) do
    List.zip([tf, idf])
    |> Enum.map(fn {t, i} -> t * i end)
    |> Result.ok
  end

  defp count_docs(model) do
    from(d in Similarity.Document,
      where: d.model_id == ^model.id
    )
    |> Repo.aggregate(:count)
    |> Result.ok
  end

  defp cos(vec1, vec2) do
    up = List.zip([vec1, vec2])
         |> Enum.reduce(0, fn {v1, v2}, acc -> (v1 * v2) + acc end)
    d1 = Enum.reduce(vec1, 0, fn v, acc -> (v * v) + acc end)
    d2 = Enum.reduce(vec2, 0, fn v, acc -> (v * v) + acc end)
    (up / (Math.sqrt(d1 * d2)))
    |> Result.ok
  end

  defp sum_square(list) do
    Enum.map(list, fn x -> x * x end)
    |> Enum.reduce(0, &(&1 + &2))
  end
end
