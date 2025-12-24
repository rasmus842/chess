defmodule Chess.Game.Props do
  alias Chess.Game.Types, as: T

  @doc """
  :player needed to validate who can make the next move,
  others boolean props needed to validate castling
  active_en_passant used to implement en passant
  """
  @enforce_keys [:player]
  defstruct [
    :player,
    :active_en_passant,
    :white_king,
    :black_king,
    :white_king_moved,
    :black_king_moved,
    :a1_rook_moved,
    :a8_rook_moved,
    :h1_rook_moved,
    :h8_rook_moved
  ]

  @type en_passant_pawn :: T.cell()
  @type en_passant_target :: T.cell()

  @type t :: %__MODULE__{
          player: T.player(),
          active_en_passant: nil | {en_passant_pawn(), en_passant_target()},
          white_king: T.cell(),
          black_king: T.cell(),
          white_king_moved: boolean(),
          black_king_moved: boolean(),
          a1_rook_moved: boolean(),
          a8_rook_moved: boolean(),
          h1_rook_moved: boolean(),
          h8_rook_moved: boolean()
        }

  @spec initial_game_props() :: t()
  def initial_game_props() do
    %__MODULE__{
      player: :white,
      active_en_passant: nil,
      white_king: {?e, 1},
      black_king: {?e, 8},
      white_king_moved: false,
      black_king_moved: false,
      a1_rook_moved: false,
      a8_rook_moved: false,
      h1_rook_moved: false,
      h8_rook_moved: false
    }
  end
end
