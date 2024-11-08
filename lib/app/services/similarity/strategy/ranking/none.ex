defmodule Similarity.Strategy.Ranking.None do
  @moduledoc """
  empty strategy, do nothing
  """

  def call(_, _, _, _, _) do
    {:ok, []}
  end
end
