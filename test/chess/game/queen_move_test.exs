defmodule Chess.Game.QueenMoveTest do
  use Chess.Game.MoveCase

  describe "Queen horizontal and vertical movements" do
    setup do
      board = %{
        {?a, 1} => {:white, :queen},
        {?a, 4} => {:black, :pawn},
        {?f, 1} => {:white, :bishop},
        {?a, 8} => {:black, :queen},
        {?f, 8} => {:black, :bishop}
      }

      {:ok, %{board: board}}
    end

    test "Queen moves horizontally 1", %{board: board} do
      move = {{?a, 1}, {?d, 1}}
      assert_move_is_ok(board, move)
    end

    test "Queen moves horizontally 2", %{board: board} do
      move = {{?a, 8}, {?d, 8}}
      assert_move_is_ok(board, move)
    end

    test "Queen moves vertically 1", %{board: board} do
      move = {{?a, 1}, {?a, 3}}
      assert_move_is_ok(board, move)
    end

    test "Queen moves vertically 2", %{board: board} do
      move = {{?a, 8}, {?a, 5}}
      assert_move_is_ok(board, move)
    end

    test "Queen cannot move if blocked 1", %{board: board} do
      move = {{?a, 1}, {?a, 5}}
      assert_move_is_error(board, move)
    end

    test "Queen cannot move if blocked 2", %{board: board} do
      move = {{?a, 8}, {?g, 8}}
      assert_move_is_error(board, move)
    end

    test "Queen cannot move like knight", %{board: board} do
      move = {{?a, 1}, {?c, 2}}
      assert_move_is_error(board, move)
    end

    test "White queen takes black pawn", %{board: board} do
      move = {{?a, 1}, {?a, 4}}
      assert_move_is_ok(board, move)
    end

    test "Black queen takes white queen", %{board: board} do
      state = %GameState{board: board, props: %Props{player: :black}}

      moves = [
        _move_black_queen = {{?a, 8}, {?c, 8}},
        _move_white_queen = {{?a, 1}, {?c, 1}},
        _black_queen_takes = {{?c, 8}, {?c, 1}}
      ]

      assert {:ok, %GameState{board: final_board}} = chain_moves(state, moves)
      assert Map.get(final_board, {?c, 1}) == {:black, :queen}
    end
  end

  describe "Queen diagonal moves" do
    setup do
      board = %{
        {?c, 1} => {:white, :queen},
        {?c, 8} => {:black, :queen}
      }

      {:ok, %{board: board}}
    end

    test "White queen moves diagonally 1", %{board: board} do
      move = {{?c, 1}, {?f, 4}}
      assert_move_is_ok(board, move)
    end

    test "White queen moves diagonally 2", %{board: board} do
      move = {{?c, 1}, {?b, 2}}
      assert_move_is_ok(board, move)
    end

    test "White queen moves diagonally 3", %{board: board} do
      move = {{?c, 1}, {?h, 6}}
      assert_move_is_ok(board, move)
    end

    test "Black queen moves diagonally", %{board: board} do
      move = {{?c, 8}, {?f, 5}}
      assert_move_is_ok(board, move)
    end

    test "Queen cannot jump non-diagonally", %{board: board} do
      move = {{?c, 1}, {?h, 4}}
      assert_move_is_error(board, move)
    end

    test "Queen cannot move if blocked", %{board: board} do
      new_board = Map.put(board, {?d, 2}, {:white, :pawn})
      move = {{?c, 1}, {?f, 4}}
      assert_move_is_error(new_board, move)
    end
  end

  describe "Queen takes diagonally" do
    setup do
      board = %{
        {?c, 1} => {:white, :queen},
        {?c, 8} => {:black, :queen},
        {?f, 5} => {:white, :pawn},
        {?f, 4} => {:black, :pawn}
      }

      {:ok, %{board: board}}
    end

    test "Queen bishop takes 1", %{board: board} do
      move = {{?c, 1}, {?f, 4}}
      assert_move_is_ok(board, move)
    end

    test "Queen bishop takes 2", %{board: board} do
      move = {{?c, 8}, {?f, 5}}
      assert_move_is_ok(board, move)
    end
  end
end
