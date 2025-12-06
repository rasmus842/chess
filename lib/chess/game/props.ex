defmodule Chess.Game.Props do
  use Chess.Game.Types

  @doc """
  :player needed to validate who can make the next move,
  others boolean props needed to validate castling
  """
  @enforce_keys [:player]
  defstruct [
    :player,
    white_king_moved: false,
    black_king_moved: false,
    a1_rook_moved: false,
    a8_rook_moved: false,
    h1_rook_moved: false,
    h8_rook_moved: false,
    en_passant_cell: nil
  ]

  @type t :: %__MODULE__{
          player: player(),
          white_king_moved: boolean(),
          black_king_moved: boolean(),
          a1_rook_moved: boolean(),
          a8_rook_moved: boolean(),
          h1_rook_moved: boolean(),
          h8_rook_moved: boolean(),
          en_passant_cell: nil | cell()
        }
end
