defmodule ChessWeb.GameChannel do
  use ChessWeb, :channel
  require Logger
  alias Chess.{GameServer, GameManager}
  alias Chess.Game.Utils

  @impl true
  def join("game:" <> game_id, _params, socket) do
    case GameManager.ensure_started(game_id) do
      {:ok, _pid} ->
        socket = assign(socket, :game_id, game_id)
        {:ok, %{}, socket}

      {:error, :not_found} ->
        {:error, %{reason: "game_not_found"}}
    end
  end

  @impl true
  def handle_in("move", payload, socket) do
    game_id = socket.assigns.game_id
    Logger.debug("Got move event for game=#{game_id}, payload=#{inspect(payload)}")

    with {:ok, move} <- parse_move(payload),
         {:ok, params} <- parse_params(payload),
         {:ok, new_state} <- GameServer.make_move(game_id, move, params) do
      broadcast!(socket, "move", new_state)
      {:reply, {:ok, new_state}, socket}
    else
      {:error, _reason} = err ->
        {:reply, err, socket}
    end
  end

  def handle_in("get_game", _payload, socket) do
    game_id = socket.assigns.game_id

    case GameManager.ensure_started(game_id) do
      {:ok, _pid} ->
        game = GameServer.get_game(game_id)
        {:reply, {:ok, game}, socket}

      {:error, :not_found} ->
        {:reply, {:error, %{reason: "game_not_found"}}, socket}
    end
  end

  @doc "Catch-all for unknown event or bad payload"
  def handle_in(event, payload, socket) do
    Logger.warning("Unexpected payload for event #{event}: #{inspect(payload)}")
    {:reply, {:error, %{reason: "bad payload"}}, socket}
  end

  defp parse_move(payload) when is_map(payload) do
    with {:ok, from} <- Map.fetch(payload, "from"),
         {:ok, to} <- Map.fetch(payload, "to") do
      Utils.parse_move({from, to})
    else
      _err -> {:error, "Invalid move"}
    end
  end

  defp parse_params(payload) when is_map(payload) do
    with {:ok, player} <- parse_player(payload),
         pawn_promotion <- Map.get(payload, "pawn_promotion"),
         promote_kind <- Utils.parse_kind(pawn_promotion),
         params <- %{player: player, pawn_promotion: promote_kind} do
      {:ok, params}
    else
      {:error, _reason} = err -> err
    end
  end

  # TODO: we should use player's UUID and infer color from that
  defp parse_player(payload) when is_map(payload) do
    case Map.get(payload, "player") do
      "white" -> {:ok, :white}
      "black" -> {:ok, :black}
      p -> {:error, "Invalid player #{p}"}
    end
  end
end
