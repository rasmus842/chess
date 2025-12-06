defmodule Chess.Game.Utils do
  use Chess.Game.Types
  alias Chess.Game.Props

  @spec new_game() :: game_state()
  def new_game(), do: {%Props{player: :white}, initial_position()}

  @spec parse_move(String.t()) :: {:ok, move()} | error()
  def parse_move(<<f1::utf8, r1::utf8, f2::utf8, r2::utf8>>)
      when f1 in ?a..?h and f2 in ?a..?h and r1 in ?1..?8 and r2 in ?1..?8 do
    move = {
      {f1, r1 - ?0},
      {f2, r2 - ?0}
    }

    {:ok, move}
  end

  def parse_move(_), do: {:error, "Invalid move"}

  @spec cell_to_string(cell()) :: String.t()
  def cell_to_string(_cell = {file, rank}) when file in ?a..?h and rank in 1..8 do
    <<file::utf8, rank + ?0>>
  end

  @spec other_player(player()) :: player()
  def other_player(player) do
    case player do
      :white -> :black
      :black -> :white
    end
  end

  @spec get_path(board(), move()) :: [cell()]
  def get_path(_board, _move = {current, target}) when current == target do
    [target]
  end

  def get_path(board, _move = {origin = {f1, r1}, target = {f2, r2}}) do
    next_file =
      cond do
        f2 > f1 -> f1 + 1
        f2 < f1 -> f1 - 1
        f2 == f1 -> f1
      end

    next_rank =
      cond do
        r2 > r1 -> r1 + 1
        r2 < r1 -> r1 - 1
        r2 == r1 -> r1
      end

    next_tile = {next_file, next_rank}
    [origin | get_path(board, {next_tile, target})]
  end

  @doc """
  first and last element are excluded from check because they
  are the origin and target.
  At origin is the piece that is being moved.
  At target is potentially a piece to be taken.
  """
  @spec path_obstructed?(board(), [cell()]) :: boolean()
  def path_obstructed?(board, path) do
    path
    |> tl()
    |> Enum.drop(-1)
    |> Enum.map(&Map.get(board, &1))
    |> Enum.any?()
  end

  @spec initial_position() :: board()
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
    |> Map.new()
  end

  @spec piece_for_initial_position(cell()) :: piece()
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
