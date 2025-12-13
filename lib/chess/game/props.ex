defmodule Chess.Game.Props do
  use Chess.Game.Types

  @doc """
  :player needed to validate who can make the next move,
  others boolean props needed to validate castling
  active_en_passant used to implement en passant
  """
  @enforce_keys [:player]
  defstruct [
    :player,
    :white_king_moved,
    :black_king_moved,
    :a1_rook_moved,
    :a8_rook_moved,
    :h1_rook_moved,
    :h8_rook_moved,
    active_en_passant: nil,
  ]

  @type en_passant_pawn :: cell()
  @type en_passant_target :: cell()

  @type t :: %__MODULE__{
          player: player(),
          white_king_moved: boolean(),
          black_king_moved: boolean(),
          a1_rook_moved: boolean(),
          a8_rook_moved: boolean(),
          h1_rook_moved: boolean(),
          h8_rook_moved: boolean(),
          active_en_passant: nil | {en_passant_pawn(), en_passant_target()},
        }
end
