defmodule Similarity.Strategy.Ranking.TfIdfTest do
  use ExUnit.Case
  use App.DataCase
  import App.Factory
  alias Similarity.Strategy.Ranking

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
    {:ok, models: [tf_idf: tf_idf, bm25: bm25], doc1: doc1, doc2: doc2}
  end

  test "test ranking", state do
    doccounts = %{"test1" => 2, "test" => 1, "test0" => 1}
    doccounts_2 = %{"test2" => 2, "test" => 1, "test3" => 1}
    {:ok, res} = Ranking.TfIdf.call(state[:doc1].id, doccounts, 2, state[:doc2].id, doccounts_2)
    assert(is_tuple(res))
    {doc, ranked, val} = res
    assert(doc == state[:doc1].id)
    assert(ranked == state[:doc2].id)
    assert(is_number(val))
  end
end
