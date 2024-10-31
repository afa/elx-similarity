defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AppWeb.Api, as: :api do
    pipe_through :api

    scope "/v1", V1, as: :v1 do
      scope "/words", as: :words do
        get "/", WordsController, :index
      end

      scope "/texts", as: :texts do
        get "/", TextsController, :index
        get "/search", TextsController, :search
        post "/create", TextsController, :create
        post "/update/:identifier", TextsController, :update
        delete "/:identifier", TextsController, :destroy
      end

      scope "/ranks", as: :ranks do
        get "/:document_key", RanksController, :show
        post "/clean", RanksController, :clean
      end

      get "/", DashboardController, :index
      # get "/:key", DashboardController, :show
    end
  end
end
