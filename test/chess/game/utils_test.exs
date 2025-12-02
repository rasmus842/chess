defmodule ChessGameTest do
  use ExUnit.Case, async: true
  import Chess.Game.Utils

  test "Creates new game" do
    {player, board} = new_game()

    assert player == :white
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
end
