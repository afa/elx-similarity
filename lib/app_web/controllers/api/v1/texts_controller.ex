defmodule AppWeb.Api.V1.TextsController do
  use AppWeb, :controller

  def index(con, _params) do
    con
    |> json([:some, %{a: 1}])
  end
end