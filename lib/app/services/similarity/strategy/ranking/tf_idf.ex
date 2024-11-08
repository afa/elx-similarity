defmodule Similarity.Strategy.Ranking.TfIdf do
  @moduledoc """
  calculating similarity using tf-idf model

  doc_id: internal document id for rankable document
  doc_counts: map with token => count in doc pairs
  total: documents count in corpus
  rank_id: same as doc_id for document with wich doc_id will be ranked
  ranc_counts: same as doc_counts for rank document

  return tuple with doc_id, rank_id and calculated rank between them
  """

  require Result
  require Math

  def call(doc_id, doc_counts, total, rank_id, rank_counts) do
    with keys <- Enum.concat(Map.keys(doc_counts), Map.keys(rank_counts))
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
      {doc_id, rank_id, val}
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
    total = Enum.reduce(counts, 0, fn {_, v}, acc -> acc + v end)
    Enum.map(keys, fn k -> Map.get(counts, k, 0) / total end)
    |> Result.ok
  end

  defp calc_tfidf(tf, idf) do
    List.zip([tf, idf])
    |> Enum.map(fn {t, i} -> t * i end)
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
end
