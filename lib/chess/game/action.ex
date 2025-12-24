defmodule Chess.Game.Action do
  alias Chess.Game.Types, as: T
  alias Chess.Game.GameState

  @doc """
  Data required to make chess move including:
  The player making the move,
  The game state - props and board
  Special parameters (pawn promotion)
  """
  @enforce_keys [:game_state, :move, :params]
  defstruct [
    :game_state,
    :move,
    :params
  ]

  @type params :: %{
          required(:player) => T.player(),
          optional(:pawn_promotion) => T.kind()
        }

  @type t :: %__MODULE__{
          game_state: GameState.t(),
          move: T.move(),
          params: params()
        }
end
