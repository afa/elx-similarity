defmodule Similarity.Token do
  use Ecto.Schema
  import Ecto.Query

  schema "similarity_token" do
    field :value, :string
    has_many :counts, Similarity.TokenCount
  end

  def total do
    from(
      m in Similarity.Token,
      select: count()
    )
    |> App.Repo.one
  end
end