defmodule Chess.Game.KnightMoveTest do
  use Chess.Game.MoveCase

  describe "Knight moves" do
    setup do
      board = %{
        {?c, 1} => {:white, :knight},
        {?g, 8} => {:black, :knight}
      }

      {:ok, %{board: board}}
    end

    test "White knight move 1", %{board: board} do
      move = {{?c, 1}, {?d, 3}}
      assert_move_is_ok(board, move)
    end

    test "White knight move 2", %{board: board} do
      move = {{?c, 1}, {?e, 2}}
      assert_move_is_ok(board, move)
    end

    test "Black knight move 1", %{board: board} do
      move = {{?g, 8}, {?f, 6}}
      assert_move_is_ok(board, move)
    end

    test "Black knight move 2", %{board: board} do
      move = {{?g, 8}, {?h, 6}}
      assert_move_is_ok(board, move)
    end

    test "Knight cannot move diagonally", %{board: board} do
      move = {{?g, 8}, {?e, 6}}
      assert_move_is_error(board, move)
    end

    test "Knight cannot move horizontally", %{board: board} do
      move = {{?c, 1}, {?e, 1}}
      assert_move_is_error(board, move)
    end

    test "Knight cannot move vertically", %{board: board} do
      move = {{?c, 1}, {?c, 3}}
      assert_move_is_error(board, move)
    end
  end

  describe "Knight takes" do
    setup do
      board = %{
        {?b, 1} => {:white, :knight},
        {?c, 3} => {:black, :queen},
        {?b, 8} => {:black, :knight},
        {?d, 7} => {:white, :rook}
      }

      {:ok, %{board: board}}
    end

    test "White knight takes", %{board: board} do
      move = {{?b, 1}, {?c, 3}}
      assert_move_is_ok(board, move)
    end

    test "Black knight takes", %{board: board} do
      move = {{?b, 8}, {?d, 7}}
      assert_move_is_ok(board, move)
    end
  end
end
