defmodule ChessWeb.Router do
  use ChessWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ChessWeb do
    pipe_through :api
    
    post "/game", GameController, :create
    get "/game/:id", GameController, :show
    
    # TODO: join game that invited to
    # post "/game/:id/join", GameController, :join

    # TODO: list all games by, player, status, recency
    # get "/game", GameController, :index
  end
end
