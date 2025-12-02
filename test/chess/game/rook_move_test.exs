defmodule Chess.Game.RookMoveTest do
  use Chess.Game.MoveCase

  setup do
    board = %{
      {?a, 1} => {:white, :rook},
      {?a, 4} => {:black, :pawn},
      {?f, 1} => {:white, :bishop},
      {?a, 8} => {:black, :rook},
      {?f, 8} => {:black, :bishop}
    }

    {:ok, %{board: board}}
  end

  describe "Rook moves" do
    test "Rook moves horizontally 1", %{board: board} do
      move = {{?a, 1}, {?d, 1}}
      assert_move_is_ok(board, move)
    end

    test "Rook moves horizontally 2", %{board: board} do
      move = {{?a, 8}, {?d, 8}}
      assert_move_is_ok(board, move)
    end

    test "Rook moves vertically 1", %{board: board} do
      move = {{?a, 1}, {?a, 3}}
      assert_move_is_ok(board, move)
    end

    test "Rook moves vertically 2", %{board: board} do
      move = {{?a, 8}, {?a, 5}}
      assert_move_is_ok(board, move)
    end

    test "Rook cannot move if blocked 1", %{board: board} do
      move = {{?a, 1}, {?a, 5}}
      assert_move_is_error(board, move)
    end

    test "Rook cannot move if blocked 2", %{board: board} do
      move = {{?a, 8}, {?g, 8}}
      assert_move_is_error(board, move)
    end

    test "Rook cannot move diagonally 1", %{board: board} do
      move = {{?a, 1}, {?d, 4}}
      assert_move_is_error(board, move)
    end

    test "Rook cannot move diagonally 2", %{board: board} do
      move = {{?a, 8}, {?h, 1}}
      assert_move_is_error(board, move)
    end

    test "Rook cannot move like knight", %{board: board} do
      move = {{?a, 1}, {?c, 2}}
      assert_move_is_error(board, move)
    end
  end

  describe "Rook takes" do
    test "White rook takes black pawn", %{board: board} do
      move = {{?a, 1}, {?a, 4}}
      assert_move_is_ok(board, move)
    end

    test "Black rook takes white rook", %{board: board} do
      state = {:black, board}

      moves = [
        _move_black_rook = {{?a, 8}, {?c, 8}},
        _move_white_rook = {{?a, 1}, {?c, 1}},
        _black_rook_takes = {{?a, 8}, {?c, 8}}
      ]

      assert {:ok, final_board} = chain_moves(state, moves)
      assert Map.get(final_board, {?c, 8}) == {:black, :rook}
    end
  end
end
