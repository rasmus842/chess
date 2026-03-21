defmodule Chess.GameManager do
  use Chess.Game.Helper
  alias Chess.GameServer

  @type game_id :: String.t()
  @type player_id :: String.t()
  @type new_game_opts :: %{
          required(:white) => player_id(),
          required(:black) => player_id()
        }
  @type game :: %{
          required(:game_id) => game_id(),
          required(:game_state) => GameState.t(),
          required(:white) => player_id(),
          required(:black) => player_id()
        }

  @spec create_new_game(new_game_opts()) :: T.result(game_id())
  def create_new_game(%{white: white, black: black}) do
    game_id = Ecto.UUID.generate()

    game = %{
      game_id: game_id,
      game_state: GameState.new(),
      white: white,
      black: black
    }

    case DynamicSupervisor.start_child(Chess.GameSupervisor, {Chess.GameServer, game}) do
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
end
