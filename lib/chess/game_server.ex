defmodule Chess.GameServer do
  use GenServer
alias Chess.GameManager
  use Chess.Game.Helper

  @type game_id :: String.t()

  def child_spec(init_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [init_arg]},
      restart: :transient
    }
  end

  def start_link(%{game_id: game_id} = state) do
    GenServer.start_link(__MODULE__, state, name: via(game_id))
  end

  def via(game_id), do: {:via, Registry, {Chess.GameRegistry, game_id}}
  
  @spec get_game(game_id()) :: GameManager.game()
  def get_game(game_id) do
    GenServer.call(via(game_id), :get_game)
  end

  @spec make_move(game_id(), T.move(), Action.params()) :: T.result(GameState.t())
  def make_move(game_id, move, params) do
    GenServer.call(via(game_id), {:move, move, params})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:get_game, _from, game) do
    {:reply, game, game}
  end

  @impl true
  def handle_call({:move, move, params}, _from, game) do
    action = %Action{game_state: game.game_state, move: move, params: params}
    result = Chess.Game.Move.make_move(action)

    case result do
      {:ok, new_state} -> {:reply, {:ok, new_state}, %{game | game_state: new_state}}
      {:error, reason} -> {:reply, {:error, reason}, game}
    end
  end
end
