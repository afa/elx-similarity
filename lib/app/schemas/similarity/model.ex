defmodule Similarity.Model do
  @moduledoc """
  statistical model
  name - unique internal behavior identifier

  their knows how to select ranking strategy for model
  """

  use Ecto.Schema
  import Ecto.Query

  @derive {Jason.Encoder, only: [:id, :name, :state]}

  schema "similarity_model" do
    field :name, :string
    field :state, Ecto.Enum, values: [disabled: 0, enabled: 1]
    field :avg_doc_length, :float
    has_many :documents, Similarity.Document
  end

  def active do
    q = from m in Similarity.Model,
      where: m.state == :enabled,
      select: m
    App.Repo.all(q)
  end

  @doc """
  select ranking strategy for model
  """
  def strategy(model) do
    case model.name do
      "tf_idf" ->
        Similarity.Strategy.Ranking.TfIdf
      "bm25" ->
        Similarity.Strategy.Ranking.Bm25
      _ ->
        Similarity.Strategy.Ranking.None
    end
  end
end
