defmodule ChessWeb.Router do
  use ChessWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated_api do
    plug :accepts, ["json"]
    plug SmoothAuth.Plugs.RequireAuthenticated
  end

  scope "/api", ChessWeb do
    pipe_through :api

    scope "/auth" do
      post "/signup/request", AuthController, :request_signup
      post "/signup/verify", AuthController, :verify_signup

      post "/login/request", AuthController, :request_login
      post "/login/verify", AuthController, :verify_login
      post "/refresh", AuthController, :refresh
      post "/logout", AuthController, :logout
    end

    post "/game", GameController, :create
    get "/game/:id", GameController, :show

    # TODO: join game that invited to
    # post "/game/:id/join", GameController, :join

    # TODO: list all games by, player, status, recency
    # get "/game", GameController, :index
  end

  scope "/api", ChessWeb do
    pipe_through :authenticated_api

    get "/auth/me", AuthController, :me
  end
end
