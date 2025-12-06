defmodule Chess.Game.PawnMoveTest do
  use Chess.Game.MoveCase

  describe "Pawn movements" do
    setup do
      board = %{
        {?a, 2} => {:white, :pawn},
        {?a, 7} => {:black, :pawn},
        {?g, 7} => {:black, :pawn},
        {?g, 6} => {:black, :pawn}
      }

      {:ok, %{board: board}}
    end

    test "white pawn moves forward one step correctly", %{board: board} do
      move = {{?a, 2}, {?a, 3}}
      assert_move_is_ok(board, move)
    end

    test "black pawn moves forward one step correctly", %{board: board} do
      move = {{?a, 7}, {?a, 6}}
      assert_move_is_ok(board, move)
    end

    test "pawn cannot move backward", %{board: board} do
      move = {{?a, 2}, {?a, 1}}
      assert_move_is_error(board, move)
    end

    test "pawn cannot move sideways", %{board: board} do
      move = {{?a, 2}, {?b, 2}}
      assert_move_is_error(board, move)
    end

    test "pawn cannot move diagonally if not taking 1", %{board: board} do
      move = {{?a, 2}, {?b, 3}}
      assert_move_is_error(board, move)
    end

    test "pawn cannot move diagonally if not taking 2", %{board: board} do
      move = {{?a, 7}, {?b, 6}}
      assert_move_is_error(board, move)
    end

    test "White pawn jump", %{board: board} do
      move = {{?a, 2}, {?a, 4}}
      assert_move_is_ok(board, move)
    end

    test "Black pawn jump", %{board: board} do
      move = {{?a, 7}, {?a, 5}}
      assert_move_is_ok(board, move)
    end

    test "pawn cannot jump if blocked", %{board: board} do
      move = {{?g, 7}, {?g, 5}}
      assert_move_is_error(board, move)
    end
  end

  describe "Pawn takes" do
    setup do
      board = %{
        {?a, 2} => {:white, :pawn},
        {?b, 4} => {:black, :pawn},
        {?d, 4} => {:white, :pawn},
        {?e, 5} => {:black, :pawn},
        {?h, 4} => {:white, :pawn},
        {?h, 5} => {:black, :pawn},
        {?a, 7} => {:black, :pawn},
        {?b, 5} => {:white, :pawn}
      }

      {:ok, %{board: board}}
    end

    test "White pawn takes black piece", %{board: board} do
      move = {{?d, 4}, {?e, 5}}
      assert_move_is_ok(board, move)
    end

    test "Black pawn takes white piece", %{board: board} do
      move = {{?e, 5}, {?d, 4}}
      assert_move_is_ok(board, move)
    end

    test "pawn cannot take forwards", %{board: board} do
      move = {{?h, 4}, {?h, 5}}
      assert_move_is_error(board, move)
    end

    test "En passant - white pawn takes black", %{board: board} do
      state =
        {%Props{player: :black}, board}

      moves = [
        _black_pawn_jumps = {{?a, 7}, {?a, 5}},
        _white_pawn_takes = {{?b, 5}, {?a, 6}}
      ]

      assert {:ok, _state} = chain_moves(state, moves)
    end

    test "En passant - black pawn takes white", %{board: board} do
      state =
        {%Props{player: :white}, board}

      moves = [
        _white_pawn_jumps = {{?a, 2}, {?a, 4}},
        _black_pawn_takes = {{?b, 4}, {?a, 3}}
      ]

      assert {:ok, _state} = chain_moves(state, moves)
    end

    test "En passant not possible afterwards", %{board: board} do
      state =
        {%Props{player: :black}, board}

      moves = [
        _black_pawn_jumps = {{?a, 7}, {?a, 5}},
        _white_pawn_moves = {{?d, 4}, {?d, 5}},
        _black_pawn_moves = {{?e, 5}, {?e, 4}},
        _white_pawn_tries_en_passant = {{?b, 5}, {?a, 6}}
      ]

      assert {:error, _} = chain_moves(state, moves)
    end
  end
end
