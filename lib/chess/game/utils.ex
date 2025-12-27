defmodule Chess.Game.Utils do
  alias Chess.Game.Types, as: T

  @spec parse_move(String.t()) :: T.result(T.move())
  def parse_move(<<f1::utf8, r1::utf8, f2::utf8, r2::utf8>>)
      when f1 in ?a..?h and f2 in ?a..?h and r1 in ?1..?8 and r2 in ?1..?8 do
    move = {
      {f1, r1 - ?0},
      {f2, r2 - ?0}
    }

    {:ok, move}
  end

  def parse_move(_), do: {:error, "Invalid move"}

  @spec cell_to_string(T.cell()) :: String.t()
  def cell_to_string(_cell = {file, rank}) when file in ?a..?h and rank in 1..8 do
    <<file::utf8, rank + ?0>>
  end

  @spec other_player(T.player()) :: T.player()
  def other_player(player) do
    case player do
      :white -> :black
      :black -> :white
    end
  end

  @spec has_piece(T.board(), T.cell(), T.color()) :: boolean()
  def has_piece(board, cell, color) do
    case Map.get(board, cell) do
      {c, _k} when c == color -> true
      _ -> false
    end
  end
  
  @spec has_piece(T.board(), T.cell(), T.color(), T.kind()) :: boolean()
  def has_piece(board, cell, color, kind) do
    case Map.get(board, cell) do
      {c, k} when c == color and k == kind -> true
      _ -> false
    end
  end

  @spec get_path_to_cell(T.cell(), (T.file(), T.rank() -> T.cell())) :: [T.cell()]
  def get_path_to_cell(target, backtracker) do
    origin = get_origin_cell(target, backtracker)

    if origin == target do
      []
    else
      get_path({origin, target})
    end
  end

  @spec get_origin_cell(T.cell(), (T.file(), T.rank() -> T.cell())) :: T.cell()
  defp get_origin_cell(target = {f, r}, backtracker) do
    next_cell = backtracker.(f, r)

    if cell_in_bounds?(next_cell) do
      get_origin_cell(next_cell, backtracker)
    else
      target
    end
  end

  @spec get_path(T.move()) :: [T.cell()]
  def get_path(_move = {current, target}) when current == target do
    [target]
  end

  def get_path(_move = {origin = {f1, r1}, target = {f2, r2}}) do
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
    [origin | get_path({next_tile, target})]
  end

  @doc """
  first and last element are excluded from check because they
  are the origin and target.
  At origin is the piece that is being moved.
  At target is potentially a piece to be taken.
  """
  @spec path_obstructed?(T.board(), [T.cell()]) :: boolean()
  def path_obstructed?(board, path) do
    path
    |> tl()
    |> Enum.drop(-1)
    |> Enum.map(&Map.get(board, &1))
    |> Enum.any?()
  end

  @spec move_obstructed?(T.board(), T.move()) :: boolean()
  def move_obstructed?(board, move) do
    path = get_path(move)
    path_obstructed?(board, path)
  end

  @spec move_in_bounds?(T.move()) :: boolean()
  def move_in_bounds?(_move = {origin, target}) do
    cell_in_bounds?(origin) and cell_in_bounds?(target)
  end

  @spec cell_in_bounds?(T.cell()) :: boolean()
  def cell_in_bounds?(_cell = {f, r}) do
    f >= ?a and f <= ?h and
      r >= 1 and r <= 8
  end
end
