defmodule Chess.Game.UtilsTest do
  use ExUnit.Case, async: true
  import Chess.Game.Utils
  alias Chess.Game.Props

  test "Creates new game" do
    {props, board} = new_game()

    assert %Props{player: :white} == props
    assert Map.get(board, {?a, 2}) == {:white, :pawn}
    assert Map.get(board, {?a, 1}) == {:white, :rook}
    assert Map.get(board, {?d, 7}) == {:black, :pawn}
    assert Map.get(board, {?d, 8}) == {:black, :queen}
  end

  test "Parses valid move" do
    valid_cases = %{
      "a2a3" => {{?a, 2}, {?a, 3}},
      "h8b7" => {{?h, 8}, {?b, 7}},
      "b1c3" => {{?b, 1}, {?c, 3}}
    }

    for {input, expected} <- valid_cases do
      assert parse_move(input) == {:ok, expected}
    end
  end

  test "Does not parse invalid move" do
    invalid_cases = ["j8b7", "asdf", 2, :asdfg, "invalid"]

    for input <- invalid_cases do
      assert parse_move(input) == {:error, "Invalid move"}
    end
  end

  test "Converts cell to string" do
    cases = %{
      {?a, 2} => "a2",
      {?f, 8} => "f8",
      {?c, 1} => "c1"
    }

    for {cell, expected} <- cases do
      assert cell_to_string(cell) == expected
    end
  end

  describe "Path tests -" do
    setup do
      board = %{
        {?a, 1} => {:white, :rook},
        {?a, 7} => {:black, :pawn},
        {?a, 8} => {:black, :rook},
        {?b, 2} => {:white, :pawn},
        {?c, 1} => {:white, :bishop},
        {?h, 6} => {:black, :pawn}
      }

      {:ok, %{board: board}}
    end

    test "Straigth obstructed path", %{board: board} do
      move = {{?a, 1}, {?a, 8}}
      path = get_path(board, move)
      assert path == [{?a, 1}, {?a, 2}, {?a, 3}, {?a, 4}, {?a, 5}, {?a, 6}, {?a, 7}, {?a, 8}]
      assert path_obstructed?(board, path)
    end

    test "Straigth unobstructed path", %{board: board} do
      move = {{?a, 1}, {?a, 7}}
      path = get_path(board, move)
      assert path == [{?a, 1}, {?a, 2}, {?a, 3}, {?a, 4}, {?a, 5}, {?a, 6}, {?a, 7}]
      assert not path_obstructed?(board, path)
    end

    test "Diagonal obstructed path", %{board: board} do
      move = {{?c, 1}, {?a, 3}}
      path = get_path(board, move)
      assert path == [{?c, 1}, {?b, 2}, {?a, 3}]
      assert path_obstructed?(board, path)
    end

    test "Diagonal unobstructed path", %{board: board} do
      move = {{?c, 1}, {?h, 6}}
      path = get_path(board, move)
      assert path == [{?c, 1}, {?d, 2}, {?e, 3}, {?f, 4}, {?g, 5}, {?h, 6}]
      assert not path_obstructed?(board, path)
    end
  end
end
