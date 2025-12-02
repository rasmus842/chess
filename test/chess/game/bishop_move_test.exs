defmodule Chess.Game.BishopMoveTest do
  use Chess.Game.MoveCase

  describe "Bishop moves" do
    setup do
      board = %{
        {?c, 1} => {:white, :bishop},
        {?c, 8} => {:black, :bishop}
      }

      {:ok, %{board: board}}
    end

    test "White bishop moves diagonally 1", %{board: board} do
      move = {{?c, 1}, {?f, 4}}
      assert_move_is_ok(board, move)
    end

    test "White bishop moves diagonally 2", %{board: board} do
      move = {{?c, 1}, {?b, 2}}
      assert_move_is_ok(board, move)
    end

    test "White bishop moves diagonally 3", %{board: board} do
      move = {{?c, 1}, {?h, 6}}
      assert_move_is_ok(board, move)
    end

    test "Black bishop moves diagonally", %{board: board} do
      move = {{?c, 8}, {?f, 5}}
      assert_move_is_ok(board, move)
    end

    test "Bishop cannot move like rook 1", %{board: board} do
      move = {{?c, 1}, {?a, 1}}
      assert_move_is_error(board, move)
    end

    test "Bishop cannot move like rook 2", %{board: board} do
      move = {{?c, 1}, {?c, 5}}
      assert_move_is_error(board, move)
    end

    test "Bishop cannot move like knight", %{board: board} do
      move = {{?c, 1}, {?b, 3}}
      assert_move_is_error(board, move)
    end

    test "Bishop cannot jump non-diagonally", %{board: board} do
      move = {{?c, 1}, {?h, 4}}
      assert_move_is_error(board, move)
    end

    test "Bishop cannot move if blocked", %{board: board} do
      new_board = Map.put(board, {?d, 2}, {:white, :pawn})
      move = {{?c, 1}, {?f, 4}}
      assert_move_is_error(new_board, move)
    end
  end

  describe "Bishop takes" do
    setup do
      board = %{
        {?c, 1} => {:white, :bishop},
        {?c, 8} => {:black, :bishop},
        {?f, 5} => {:white, :pawn},
        {?f, 4} => {:black, :pawn}
      }

      {:ok, %{board: board}}
    end

    test "White bishop takes", %{board: board} do
      move = {{?c, 1}, {?f, 4}}
      assert_move_is_ok(board, move)
    end

    test "Black bishop takes", %{board: board} do
      move = {{?c, 8}, {?f, 5}}
      assert_move_is_ok(board, move)
    end
  end
end
