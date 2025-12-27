defmodule Chess.Game.Props do
  alias Chess.Game.Types, as: T

  @doc """
  :player needed to validate who can make the next move,
  others boolean props needed to validate castling
  active_en_passant used to implement en passant
  """
  defstruct player: :white,
            active_en_passant: nil,
            white_king: nil,
            black_king: nil,
            white_king_moved: false,
            black_king_moved: false,
            a1_rook_moved: false,
            a8_rook_moved: false,
            h1_rook_moved: false,
            h8_rook_moved: false

  @type en_passant_pawn :: T.cell()
  @type en_passant_target :: T.cell()

  @type t :: %__MODULE__{
          player: T.player(),
          active_en_passant: nil | {en_passant_pawn(), en_passant_target()},
          white_king: nil | T.cell(),
          black_king: nil | T.cell(),
          white_king_moved: boolean(),
          black_king_moved: boolean(),
          a1_rook_moved: boolean(),
          a8_rook_moved: boolean(),
          h1_rook_moved: boolean(),
          h8_rook_moved: boolean()
        }

  @spec from_board(T.board(), keyword()) :: t()
  def from_board(board, attrs \\ []) do
    white_king_cell =
      Enum.find_value(board, fn {cell, piece} ->
        case piece do
          {:white, :king} -> cell
          _ -> nil
        end
      end)

    black_king_cell =
      Enum.find_value(board, fn {cell, piece} ->
        case piece do
          {:black, :king} -> cell
          _ -> nil
        end
      end)

    %__MODULE__{white_king: white_king_cell, black_king: black_king_cell}
    |> struct(attrs)
  end
end
