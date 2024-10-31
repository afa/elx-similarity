defmodule Api.V1.Ranks.Show do
  @moduledoc """
  prepare result for ranks#show or :error
  TODO: add filter by model (v2?)
  """
  import Ecto.Query

  @doc """
  loads similarity ranks for active models, filtered , split by model, return json or :error
  """
  def call(key, %{models: filter}) when is_binary(key) do
    # filter = ["bm25", "tf_idf"]
    min_value = 0.0
    data = from(r in Similarity.DocumentRank,
      join: d in Similarity.Document,
      on: d.id == r.left_id or d.id == r.right_id,
      join: m in Similarity.Model,
      on: d.model_id == m.id,
      join: lft in Similarity.Document,
      on: lft.id == r.left_id,
      join: rgt in Similarity.Document,
      on: rgt.id == r.right_id,
      where: d.main_object == ^key and m.state == :enabled and m.name in ^filter and r.rank > ^min_value,
      select: %{rank: r.rank, id: d.id, model: m.name,
        left: r.left_id, left_object: lft.main_object, right: r.right_id, right_object: rgt.main_object},
      order_by: [desc: r.rank])
      |> App.Repo.all
      |> Enum.map(&select_similar_doc/1)
      |> Enum.uniq_by(fn item -> item.id end)
      |> Enum.group_by(fn item -> item.model end, fn item -> %{rank: item.rank, identifier: item.main_object} end)
    {:ok, %{ranks: data}}
  end
  def call(_), do: {:error, "invalid key format"}

  defp select_similar_doc(item) do
    doc = [{item.left, item.left_object}, {item.right, item.right_object}]
          |> Enum.find(fn i -> elem(i, 0) != item.id end)
    %{rank: item.rank, main_object: elem(doc, 1), id: elem(doc, 0), model: item.model}
  end
end
