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
          "player" => _player,
          "from" => from,
          "to" => to
        } = payload,
        socket
      ) do
    game_id = socket.assigns.game_id
    Logger.debug("Got move event for game=#{game_id}, payload=#{inspect(payload)}")

    with {:ok, move} <- Utils.parse_move({from, to}),
         params <- get_params(payload),
         {:ok, new_state} <- GameServer.make_move(game_id, move, params) do
      broadcast!(socket, "move_made", %{state: new_state})
      {:reply, {:ok, "ok"}, socket}
    else
      {:error, _reason} = err ->
        {:reply, err, socket}
    end
  end

  def handle_in("move", payload, socket) do
    Logger.warning("Unexpected payload for move: #{inspect(payload)}")
    {:reply, {:error, %{reason: "bad payload"}}, socket}
  end

  defp get_params(%{"player" => player} = payload) do
    pawn_promotion =
      case Map.get(payload, "pawn_promotion") do
        nil -> nil
        kind -> Utils.parse_kind(kind)
      end

    %{player: player, pawn_promotion: pawn_promotion}
  end
end
