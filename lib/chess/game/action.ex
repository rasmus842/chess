defmodule Chess.Game.Action do
  use Chess.Game.Types

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
          player: player(),
          pawn_promotion: kind()
        }

  @type t :: %__MODULE__{
          game_state: game_state(),
          move: move(),
          params: params()
        }
end
