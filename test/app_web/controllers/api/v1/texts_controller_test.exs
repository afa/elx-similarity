defmodule AppWeb.Api.V1.TextsControllerTest do
  use AppWeb.ConnCase, async: true
  import App.Factory

  setup do
    insert!(:model)
    :ok
  end
  test "GET /api/v1/texts/", %{conn: conn} do
    get(conn, ~p"/api/v1/texts/")
    |> json_response(200)
  end

  test "POST /api/v1/texts/create", %{conn: conn} do
    post(conn, ~p"/api/v1/texts/create", %{prefix: "test", name: "", text: "test1 test2 test3\ntest4", models: "tf_idf"})
    |> json_response(200)
  end

  test "POST /api/v1/texts/create with invalid params", %{conn: conn} do
    rez = post(conn, ~p"/api/v1/texts/create", %{name: "", text: "asd"})
          |> json_response(422)
    assert(Map.has_key?(rez, "error"))
  end
end
