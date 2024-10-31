defmodule Similarity.Strategy.Ranking.TfIdfTest do
  use ExUnit.Case
  use App.DataCase
  import App.Factory

  setup do
    tf_idf = insert!(:model, %{name: "tf_idf", state: :enabled})
    bm25 = insert!(:model, %{name: "bm25", state: :disabled})
    doc1 = insert!(:document, %{model_id: tf_idf.id, name: "test1", main_object: "test1", text: "test test1 test0"})
    doc2 = insert!(:document, %{model_id: tf_idf.id, name: "test2", main_object: "test2", text: "test test2 test3"})
    t = insert!(:token, value: "test")
    t1 = insert!(:token, value: "test1")
    t0 = insert!(:token, value: "test0")
    t2 = insert!(:token, value: "test2")
    t3 = insert!(:token, value: "test3")
    insert!(:token_count, document_id: doc1.id, token_id: t.id, count: 1)
    insert!(:token_count, document_id: doc2.id, token_id: t.id, count: 1)
    insert!(:token_count, document_id: doc1.id, token_id: t1.id, count: 2)
    insert!(:token_count, document_id: doc1.id, token_id: t0.id, count: 1)
    insert!(:token_count, document_id: doc2.id, token_id: t2.id, count: 2)
    insert!(:token_count, document_id: doc2.id, token_id: t3.id, count: 1)
    {:ok, models: [tf_idf: tf_idf, bm25: bm25], docs: [doc1, doc2]}
  end

  test "test ranking", state do
    {:ok, res} = Similarity.Strategy.Ranking.TfIdf.call(hd(state[:docs]).id)
    assert(is_list(res))
    [data | _] = res
    assert(is_tuple(data))
    {doc, ranked, val} = data
    assert(doc == hd(state[:docs]).id)
    assert(ranked == hd(tl(state[:docs])).id)
    assert(is_number(val))
    # {:ok, res} = Api.V1.Ranks.Show.call("test1", %{models: ["tf_idf"]})
    # assert(Map.has_key?(res.ranks, "tf_idf"))
    # {:ok, list} = Map.fetch(res.ranks, "tf_idf")
    # assert(length(list) == 2)
  end
end
