defmodule AppWeb.Api.V1.Ranks.ShowTest do
  use ExUnit.Case
  use App.DataCase
  import App.Factory
  alias Api.V1.Ranks

  setup do
    model = insert!(:model, %{name: "tf_idf", state: :enabled})
    bm25 = insert!(:model, %{name: "bm25", state: :disabled})
    doc1 = insert!(:document, %{model_id: model.id, name: "test1", main_object: "test1"})
    doc2 = insert!(:document, %{model_id: model.id, name: "test2", main_object: "test2"})
    doc3 = insert!(:document, %{model_id: model.id, name: "test3", main_object: "test3"})
    doc_none = insert!(:document, %{model_id: bm25.id, name: "test_", main_object: "test_"})
    insert!(:rank, %{left_id: doc1.id, right_id: doc2.id, rank: 0.7})
    insert!(:rank, %{left_id: doc2.id, right_id: doc1.id, rank: 0.7})
    insert!(:rank, %{left_id: doc1.id, right_id: doc3.id, rank: 0.1})
    insert!(:rank, %{left_id: doc3.id, right_id: doc3.id, rank: 1.0})
    insert!(:rank, %{left_id: doc_none.id, right_id: doc_none.id, rank: 1.0})
    :ok
  end

  test "load ranks for tf_idf" do
    {:ok, res} = Ranks.Show.call("test1", %{models: ["tf_idf"]})
    assert(Map.has_key?(res.ranks, "tf_idf"))
    {:ok, list} = Map.fetch(res.ranks, "tf_idf")
    assert(length(list) == 2)
  end
end
