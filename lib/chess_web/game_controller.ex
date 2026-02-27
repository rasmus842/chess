defmodule ChessWeb.GameController do
  use ChessWeb, :controller
  alias Chess.{GameServer, GameManager}

  def show(conn, %{"game_id" => game_id}) do
    with {:ok, _pid} <- GameManager.ensure_started(game_id),
         state <- GameServer.get_state(game_id) do
      conn
      |> put_status(:ok)
      |> json(state)
    else
      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "game_not_found", reason: inspect(reason)})
    end
  end

  def create(conn, %{"white" => white, "black" => black})
      when is_binary(white) and is_binary(black) do
    case GameManager.create_new_game(%{white: white, black: black}) do
      {:ok, game_id} ->
        conn
        |> put_status(:created)
        |> json(%{game_id: game_id})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "create_new_game_error", reason: inspect(reason)})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "bad_request", required: ["white", "black"]})
  end
end
