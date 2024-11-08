defmodule Api.V1.Texts.Create do
  @moduledoc """
  creates document with text in models (only active)
  splits document to words and update tokens counts
  start ranking document
  returns :ok, ids for saved documents
  """

  import Ecto.Query
  require Result
  alias App.Repo
  alias Similarity.Ranking.Tokenize

  def call(identifier, params) do
    with {:ok, docs} <- store_docs(identifier, params),
         {:ok, _} <- tokenize(docs)
    do
      ids = Enum.map(docs, fn doc -> doc.main_object end)
      Result.ok(%{ids: ids})
    else
      err ->
        {:error, err}
    end
  end

  defp tokenize(docs) do
    Enum.map(docs, &Tokenize.call(&1.id))
    |> Result.fold
  end

  defp store_docs(identifier, %{name: name, text: text, models: models}) do
    Enum.map(avail(models), fn model ->
      Repo.insert(
        %Similarity.Document{name: name, main_object: identifier, text: text, model_id: model.id, state: :created},
        returning: [:id]
      )
    end)
    |> Enum.map(fn {:ok, m} -> m end)
    |> Result.ok
    rescue
    RuntimeError ->
    {:error}
  end

  defp avail(models) do
    from(m in Similarity.Model, where: m.state == :enabled and m.name in ^models)
    |> Repo.all
  end
end
