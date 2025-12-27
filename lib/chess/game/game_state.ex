defmodule Chess.Game.GameState do
  alias Chess.Game.Types, as: T
  alias Chess.Game.Props
  alias Chess.Game.Validator.PossibleMoves

  defstruct board: %{},
            props: %Props{},
            possible_moves: %{},
            checks: %{}

  @type t :: %__MODULE__{
          board: T.board(),
          props: Props.t(),
          possible_moves: T.targets(),
          checks: T.attacks()
        }

  @spec new() :: t()
  @spec new(keyword()) :: t()
  def new(attrs \\ []) when is_list(attrs) do
    board = Keyword.get(attrs, :board, initial_position())
    props = Props.from_board(board, attrs)

    %__MODULE__{board: board, props: props}
    |> recompute()
  end

  defp recompute(state = %__MODULE__{}) do
    {moves, checks} = PossibleMoves.possible_moves(state)
    %__MODULE__{state | possible_moves: moves, checks: checks}
  end

  @spec initial_position() :: T.board()
  def initial_position() do
    ?a..?h
    |> Enum.flat_map(fn file ->
      1..8
      |> Enum.map(fn rank ->
        cell = {file, rank}
        piece = piece_for_initial_position(cell)
        {cell, piece}
      end)
    end)
    |> Enum.reject(fn {_cell, piece} -> is_nil(piece) end)
    |> Map.new()
  end

  @spec piece_for_initial_position(T.cell()) :: T.piece()
  defp piece_for_initial_position(cell) do
    case cell do
      {_, 2} -> {:white, :pawn}
      {_, 7} -> {:black, :pawn}
      {c, 1} when c in [?a, ?h] -> {:white, :rook}
      {c, 8} when c in [?a, ?h] -> {:black, :rook}
      {c, 1} when c in [?b, ?g] -> {:white, :knight}
      {c, 8} when c in [?b, ?g] -> {:black, :knight}
      {c, 1} when c in [?c, ?f] -> {:white, :bishop}
      {c, 8} when c in [?c, ?f] -> {:black, :bishop}
      {?d, 1} -> {:white, :queen}
      {?d, 8} -> {:black, :queen}
      {?e, 1} -> {:white, :king}
      {?e, 8} -> {:black, :king}
      _ -> nil
    end
  end
end
