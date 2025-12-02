defmodule Chess.Game.KingMoveTest do
  use Chess.Game.MoveCase

  describe "King moves" do
    setup do
      board = %{
        {?e, 1} => {:white, :king},
        {?e, 8} => {:black, :king}
      }

      {:ok, %{board: board}}
    end

    test "King can move 1 step horizontally", %{board: board} do
      move = {{?e, 1}, {?d, 1}}
      assert_move_is_ok(board, move)
    end

    test "King can move 1 step vertically", %{board: board} do
      move = {{?e, 8}, {?e, 7}}
      assert_move_is_ok(board, move)
    end

    test "King can move 1 step diagonally", %{board: board} do
      move = {{?e, 1}, {?d, 2}}
      assert_move_is_ok(board, move)
    end

    test "King cannot move over 1 step - 1", %{board: board} do
      move = {{?e, 1}, {?d, 3}}
      assert_move_is_error(board, move)
    end

    test "King cannot move over 1 step - 2", %{board: board} do
      move = {{?e, 8}, {?e, 6}}
      assert_move_is_error(board, move)
    end

    test "King cannot move over 1 step - 3", %{board: board} do
      move = {{?e, 1}, {?g, 1}}
      assert_move_is_error(board, move)
    end
  end

  describe "King takes" do
    setup do
      board = %{
        {?e, 1} => {:white, :king},
        {?e, 2} => {:black, :pawn},
        {?e, 8} => {:black, :king},
        {?d, 8} => {:white, :bishop}
      }

      {:ok, %{board: board}}
    end

    test "White king takes black pawn", %{board: board} do
      move = {{?e, 1}, {?e, 2}}
      assert_move_is_ok(board, move)
    end

    test "Black king takes white bishop", %{board: board} do
      move = {{?e, 8}, {?d, 8}}
      assert_move_is_ok(board, move)
    end
  end
end
