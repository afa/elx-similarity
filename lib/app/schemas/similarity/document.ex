defmodule Similarity.Document do
  @moduledoc """
  document model
  main_object: external document key
  name, text: tokenizable text, stored for indexing
  """

  use Ecto.Schema
  import Ecto.Query

  schema "similarity_document" do
    field :name, :string
    field :text, :string
    field :state, Ecto.Enum, values: [created: 0, tokenized: 1, ranked: 2]
    field :main_object, :string
    field :tokenized_at, :integer
    field :ranked_at, :integer
    belongs_to :model, Similarity.Model
  end

  def tokenized, do: from(d in Similarity.Document, where: d.state == :tokenized)
  def ranked, do: from(d in Similarity.Document, where: d.state == :ranked)

  def total(queryable \\ __MODULE__) do
    queryable
    |> select([s], count())
    |> App.Repo.one
  end
end
