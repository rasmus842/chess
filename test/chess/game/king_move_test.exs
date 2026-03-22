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

  @king_takes_board %{
    {?e, 1} => {:white, :king},
    {?e, 2} => {:black, :pawn},
    {?f, 1} => {:black, :knight},
    {?e, 8} => {:black, :king},
    {?d, 8} => {:white, :bishop}
  }

  describe "King takes" do
    test "White king takes black pawn" do
      move = {{?e, 1}, {?e, 2}}
      assert_move_is_ok(@king_takes_board, move)
    end

    test "Black king takes white bishop" do
      move = {{?e, 8}, {?d, 8}}
      assert_move_is_ok(@king_takes_board, move)
    end

    test "King cannot take protected piece" do
      move = {{?e, 1}, {?f, 1}}
      assert_move_is_error(@king_takes_board, move)
    end
  end
end
