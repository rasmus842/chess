defmodule ChessWeb.GameChannel do
  use ChessWeb, :channel
  require Logger
  alias Chess.GameServer
  alias Chess.Game.Utils

  @impl true
  def join("game:" <> game_id, _params, socket) do
    case GameServer.ensure_started(game_id) do
      {:ok, _pid} ->
        state = GameServer.get_state(game_id)
        socket = assign(socket, :game_id, game_id)
        {:ok, %{state: state}, socket}

      {:error, :not_found} ->
        {:error, %{reason: "game_not_found"}}
    end
  end

  @impl true
  def handle_in(
        "move",
        %{
          "player" => player,
          "from" => from,
          "to" => to
        } = payload,
        socket
      ) do
    game_id = socket.assigns.game_id
    Logger.debug("Got move event for game=#{game_id}, payload=#{inspect(payload)}")

    move = Utils.parse_move({from, to})

    pawn_promotion =
      case Map.get(payload, "pawn_promotion") do
        nil -> nil
        kind -> Utils.parse_kind(kind)
      end

    params = %{player: player, pawn_promotion: pawn_promotion}

    case GameServer.make_move(game_id, move, params) do
      {:ok, state} ->
        broadcast!(socket, "move_made", %{test: "test"})
        {:reply, {:ok, state}, socket}

      {:error, _reason} = err ->
        {:reply, err, socket}
    end
  end

  def handle_in("move", payload, socket) do
    Logger.warning("Unexpected payload for move: #{inspect(payload)}")
    {:reply, {:error, %{reason: "bad payload"}}, socket}
  end
end
