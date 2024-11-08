defmodule AppWeb.Api.V1.Texts.CreateTest do
  use ExUnit.Case
  use App.DataCase
  import App.Factory
  alias Api.V1.Texts

  setup do
    insert!(:model, %{name: "tf_idf", state: :enabled})
    insert!(:model, %{name: "bm25", state: :disabled})
    :ok
  end

  test "create document for single model" do
    {:ok, res} = Texts.Create.call("test", %{name: "", text: "test1 test2 test3\ntest4", models: ~w[tf_idf]})
    assert(is_map(res))
    assert(Map.has_key?(res, :ids))
    assert(Enum.member?(res.ids, "test"))
  end
end
