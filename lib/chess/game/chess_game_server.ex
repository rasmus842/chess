defmodule Chess.ChessGameServer do
  use GenServer

  @type start_opts :: [
          white_player: term(),
          black_player: term(),
          next_move: :white | :black,
          pieces: map()
        ]

  @spec start_link(start_opts()) :: GenServer.on_start()
  def start_link(opts) do
    name = Keyword.get(opts, :name, "todo")
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    {:ok, opts}
  end
end
