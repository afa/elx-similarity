defmodule App.Factory do
  @moduledoc """
  testing models factory
  """

  alias App.Repo

  def build(:model) do
    %Similarity.Model{name: "tf_idf", state: :enabled}
  end

  def build(:rank) do
    %Similarity.DocumentRank{rank: 1.0}
  end

  def build(:token) do
    %Similarity.Token{}
  end

  def build(:token_count) do
    %Similarity.TokenCount{count: 1}
  end

  def build(:document) do
    %Similarity.Document{name: "test"}
  end
  # api
  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
