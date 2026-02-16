defmodule Chess.GameServer do
  use GenServer
  use Chess.Game.Helper

  @type game_id :: String.t()
  @type player_id :: String.t()
  @type new_game_opts :: %{
          required(:white) => player_id(),
          required(:black) => player_id()
        }

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
  
  @spec create_new_game(new_game_opts()) :: T.result(game_id())
  def create_new_game(%{white: white, black: black}) do
    game_id = Ecto.UUID.generate()

    state = %{
      game_id: game_id,
      game_state: GameState.new(),
      white: white,
      black: black
    }

    case DynamicSupervisor.start_child(Chess.GameSupervisor, {__MODULE__, state}) do
      {:ok, _pid} -> {:ok, game_id}
      {:error, _} = err -> err
    end
  end

  @spec ensure_started(game_id()) :: {:ok, pid()} | {:error, :not_found}
  def ensure_started(game_id) do
    case Registry.lookup(Chess.GameRegistry, game_id) do
      [{pid, _value}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

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
