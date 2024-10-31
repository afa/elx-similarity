defmodule AppWeb.Api.V1.RanksController do
  use AppWeb, :controller
  # require OK

  @moduledoc """
  API for documents ranks
  """

  @doc """
  renders limited list of the most ranked for document_key documents
  """
  def show(con, %{"document_key" => key} = params) do
    models = case Map.fetch(params, "models") do
      {:ok, list} -> String.split(list, ",")
      :error ->
        Similarity.Model.active
        |> Enum.map(fn m -> m.name end)
    end
    case  Api.V1.Ranks.Show.call(key, %{models: models}) do
      {:ok, res} -> json(con, res)
      {:error, err} ->
        con
        |> put_status(:unprocessable_entity)
        |> json(%{error: err})
    end
  end
end
