defmodule ChessWeb.HomePageController do
  use ChessWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
