defmodule Similarity.Ranking.Tokenize do
  @moduledoc """
  tokenizes document, stores counts
  """

  import Ecto.Query
  require Result
  alias App.Repo

  def call(doc_id) do
    with {:ok, doc} <- load_doc(doc_id),
         {:ok, name, text} <- extract_text(doc),
         {:ok, words} <- split_text(name <> " " <> text),
         {:ok, tokens} <- clean(words),
         {:ok, counts} <- count_tokens(tokens),
         {:ok, _} <- store_tokens(counts),
         {:ok, _} <- store_counts(doc, counts)
    do
      Result.ok counts
    else
      err ->
        {:error, err}
    end
  end

  defp load_doc(doc_id) do
    Repo.get(Similarity.Document, doc_id)
    |> Result.from(:document_not_found)
  end

  defp extract_text(doc) do
    {:ok, doc.name, doc.text}
  end

  defp split_text(text) do
    {:ok, String.split(text, ~r{\b}u)}
    rescue
    RintimeError ->
      {:error, "parse error"}
  end

  defp count_tokens(tokens), do: {:ok, Enum.frequencies(tokens)}

  defp clean(tokens) do
    bad_words = ["", " ", "\n"]
    Enum.reject(tokens, fn i -> i in bad_words end)
    |> Result.ok
  end

  defp store_tokens(list) do
    keys = Map.keys(list)
    exists = from(
      t in Similarity.Token,
      where: t.value in ^keys
    )
    |> App.Repo.all
    |> Enum.map(fn m -> m.value end)
    App.Repo.insert_all(
      Similarity.Token,
      Enum.map(keys -- exists, fn name -> %{value: name} end),
      returning: [:value, :id]
    )
    |> Result.ok
  end

  defp store_counts(doc, list) do
    keys = Map.keys(list)
    tokens = from(t in Similarity.Token, where: t.value in ^keys, select: [:id, :value])
             |> App.Repo.all
    store_counts_for_doc(doc, tokens, list)
  end

  defp store_counts_for_doc(doc, tokens, list) do
    inserts = Enum.map(tokens, fn token -> %{token_id: token.id, document_id: doc.id, count: list[token.value]} end)
    App.Repo.insert_all(Similarity.TokenCount, inserts, returning: [:id])
    |> Result.ok
    rescue
    err ->
    {:error, err}
  end
end
