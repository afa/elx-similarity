defmodule Similarity.DocumentRank do
  @moduledoc """
  stores calculated rank between left and right document
  """

  use Ecto.Schema

  schema "similarity_document_rank" do
    field :rank, :float
    belongs_to :left, Similarity.Document
    belongs_to :right, Similarity.Document
  end
end
