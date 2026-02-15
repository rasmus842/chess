defmodule ChessWeb.GameChannel do
  use ChessWeb, :channel
  require Logger

  @impl true
  def join("game", _params, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in(
        "move",
        %{
          "from" => from,
          "to" => to,
        },
        socket
      ) do
    Logger.info("Got move event: from=#{from}, to=#{to}")
    broadcast!(socket, "move_made", %{test: "test"})
    {:noreply, socket}
  end

  def handle_in("move", payload, socket) do
    Logger.waring("Unexpected payload for move: #{inspect(payload)}")
    {:reply, {:error, %{reason: "bad payload"}}, socket}
  end
end
