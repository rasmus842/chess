defmodule Chess.GameServer do
  use GenServer
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
  
  @spec get_state(game_id()) :: GameState.t()
  def get_state(game_id) do
    GenServer.call(via(game_id), :get_state)
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
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:move, move, params}, _from, %{game_state: state}) do
    action = %Action{game_state: state, move: move, params: params}
    result = Chess.Game.Move.make_move(action)

    case result do
      {:ok, new_state} -> {:reply, {:ok, new_state}, new_state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end
end
