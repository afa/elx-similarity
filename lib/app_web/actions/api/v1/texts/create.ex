defmodule Api.V1.Texts.Create do
  @moduledoc """
  creates document with text in models (only active)
  splits document to words and update tokens counts
  start ranking document
  returns :ok, ids for saved documents
  """

  import Ecto.Query
  require Result

  def call(identifier, %{name: name, text: text} = params) do
    with {:ok, words} <- split_text(name <> " " <> text),
         {:ok, counted} <- count_words(words),
         {:ok, list} <- apply_bad_words(counted, ["", " "]),
         {:ok, docs} <- store_docs(identifier, params),
         {:ok, _} <- store_tokens(list),
         {:ok, _} <- store_counts(docs, list)
    do
      ids = Enum.map(docs, fn doc -> doc.main_object end)
      ok(%{ids: ids})
    else
      err ->
        {:error, err}
    end
  end

  defp split_text(text) do
    {:ok, String.split(text, ~r{\b}u)}
    rescue
    RintimeError ->
      {:error, "parse error"}
  end

  defp count_words(tokens), do: {:ok, Enum.frequencies(tokens)}

  defp apply_bad_words(tokens, bad_words), do: {:ok, Map.drop(tokens, bad_words)}

  defp store_docs(identifier, %{name: name, text: text, models: models}) do
    Enum.map(avail(models), fn model ->
      App.Repo.insert(
        %Similarity.Document{name: name, main_object: identifier, text: text, model_id: model.id, state: :created},
        returning: [:id]
      )
    end)
    |> Enum.map(fn {:ok, m} -> m end)
    |> ok
    rescue
    RuntimeError ->
    {:error}
  end

  defp avail(models) do
    from(m in Similarity.Model, where: m.state == :enabled and m.name in ^models)
    |> App.Repo.all
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
    |> ok
  end

  defp store_counts(docs, list) do
    keys = Map.keys(list)
    tokens = from(t in Similarity.Token, where: t.value in ^keys, select: [:id, :value])
             |> App.Repo.all
    Enum.map(docs, fn doc -> store_counts_for_doc(doc, tokens, list) end)
    |> Result.fold
  end

  defp store_counts_for_doc(doc, tokens, list) do
    inserts = Enum.map(tokens, fn token -> %{token_id: token.id, document_id: doc.id, count: list[token.value]} end)
    App.Repo.insert_all(Similarity.TokenCount, inserts, returning: [:id])
    |> ok
    rescue
    err ->
    {:error, err}
  end

  defp ok(rez), do: {:ok, rez}
end
