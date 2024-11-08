defmodule Similarity.Ranking.Rank do
  @moduledoc """
  build ranks for document, calculating ranks with it for corpus
  limited only by model

  returns result tuple with list ids/rank tuples calculated by strategy
  """

  import Ecto.Query
  require Result
  require Math
  alias App.Repo

  def call(doc_id) do
    with {:ok, doc} <- load_doc(doc_id),
         {:ok, model} <- load_model(doc),
         {:ok, strategy} <- load_strategy(model),
         {:ok, docs} <- load_rankable(doc),
         {:ok, keys} <- load_doc_tokens(doc),
         {:ok, total} <- count_docs(model)
    do
      Enum.map(docs, &rank(strategy, doc, keys, total, &1))
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

  defp load_strategy(model) do
    Similarity.Model.strategy(model)
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

  defp rank(strategy, doc, doc_counts, total, to_rank) do
    case load_doc_tokens(to_rank) do
      {:ok, rank_counts} ->
        strategy.call(doc.id, doc_counts, total, to_rank.id, rank_counts)
      {:error, err} ->
        {:error, err}
    end
  end

  defp count_docs(model) do
    from(d in Similarity.Document,
      where: d.model_id == ^model.id
    )
    |> Repo.aggregate(:count)
    |> Result.ok
  end
end
