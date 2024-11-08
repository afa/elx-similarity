defmodule Similarity.TokenizeTest do
  use ExUnit.Case
  use App.DataCase
  import App.Factory
  alias Similarity.Ranking.Tokenize

  setup do
    tf_idf = insert!(:model, %{name: "tf_idf", state: :enabled})
    bm25 = insert!(:model, %{name: "bm25", state: :disabled})
    doc = insert!(:document, %{model_id: tf_idf.id, name: "test1", main_object: "test1", text: "test test1 test0"})
    # doce = insert!(:document, %{model_id: tf_idf.id, name: "test2", main_object: "test2", text: "test test2 test3"})
    # t = insert!(:token, value: "test")
    # t1 = insert!(:token, value: "test1")
    # t0 = insert!(:token, value: "test0")
    # t2 = insert!(:token, value: "test2")
    # t3 = insert!(:token, value: "test3")
    # insert!(:token_count, document_id: doc1.id, token_id: t.id, count: 1)
    # insert!(:token_count, document_id: doc2.id, token_id: t.id, count: 1)
    # insert!(:token_count, document_id: doc1.id, token_id: t1.id, count: 2)
    # insert!(:token_count, document_id: doc1.id, token_id: t0.id, count: 1)
    # insert!(:token_count, document_id: doc2.id, token_id: t2.id, count: 2)
    # insert!(:token_count, document_id: doc2.id, token_id: t3.id, count: 1)
    {:ok, models: [tf_idf: tf_idf, bm25: bm25], doc: doc}
  end

  test "test ranking", state do
    {:ok, res} = Tokenize.call(state[:doc].id)
    assert(is_map(res))
    %{"test1" => 2, "test" => 1} = res
  end
end
