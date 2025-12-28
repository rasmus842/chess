defmodule Chess.Game.KingCastlesTest do
  use Chess.Game.MoveCase

  describe "Castling" do
    setup do
      board = %{
        {?e, 1} => {:white, :king},
        {?a, 1} => {:white, :rook},
        {?d, 1} => {:white, :queen},
        {?h, 1} => {:white, :rook},
        {?d, 4} => {:white, :pawn}, # this blocks check
        {?e, 8} => {:black, :king},
        {?a, 8} => {:black, :rook},
        {?b, 8} => {:black, :knight},
        {?h, 8} => {:black, :rook}
      }

      {:ok, %{board: board}}
    end

    test "White castles king-side", %{board: board} do
      move = {{?e, 1}, {?g, 1}}
      %GameState{board: new_board} = assert_move_is_ok(board, move)
      assert Map.get(new_board, {?g, 1}) == {:white, :king}
      assert Map.get(new_board, {?f, 1}) == {:white, :rook}
    end

    test "White cannot castle if blocked", %{board: board} do
      move = {{?e, 1}, {?c, 1}}
      assert_move_is_error(board, move)
    end

    test "White cannot castle if in check", %{board: board} do
      altered_board = Map.put(board, {?e, 3}, {:black, :rook})
      move = {{?e, 1}, {?g, 1}}
      assert_move_is_error(altered_board, move)
    end

    test "White cannot castle if path is controlled by Black", %{board: board} do
      altered_board = Map.put(board, {?f, 3}, {:black, :rook})
      move = {{?e, 1}, {?g, 1}}
      assert_move_is_error(altered_board, move)
    end

    test "White castles queen-side", %{board: board} do
      altered_board = Map.put(board, {?d, 1}, nil)
      move = {{?e, 1}, {?c, 1}}
      %GameState{board: new_board} = assert_move_is_ok(altered_board, move)
      assert Map.get(new_board, {?c, 1}) == {:white, :king}
      assert Map.get(new_board, {?d, 1}) == {:white, :rook}
    end

    test "Black castles king-side", %{board: board} do
      move = {{?e, 8}, {?g, 8}}
      %GameState{board: new_board} = assert_move_is_ok(board, move)
      assert Map.get(new_board, {?g, 8}) == {:black, :king}
      assert Map.get(new_board, {?f, 8}) == {:black, :rook}
    end

    test "Black castles queen-side", %{board: board} do
      altered_board = Map.delete(board, {?b, 8})
      move = {{?e, 8}, {?c, 8}}
      %GameState{board: new_board} = assert_move_is_ok(altered_board, move)
      assert Map.get(new_board, {?c, 8}) == {:black, :king}
      assert Map.get(new_board, {?d, 8}) == {:black, :rook}
    end

    test "Black cannot castle if blocked", %{board: board} do
      move = {{?e, 8}, {?c, 1}}
      assert_move_is_error(board, move)
    end

    test "Black cannot castle if path is checked", %{board: board} do
      altered_board = Map.put(board, {?f, 7}, {:white, :rook})
      move = {{?e, 8}, {?g, 8}}
      assert_move_is_error(altered_board, move)
    end
    
    test "Black cannot castle if path is checked by pawn", %{board: board} do
      altered_board = Map.put(board, {?e, 7}, {:white, :pawn})
      move = {{?e, 8}, {?g, 8}}
      assert_move_is_error(altered_board, move)
    end

    test "Cannot castle if king already moved", %{board: board} do
      state = GameState.new(board: board, player: :black)

      moves = [
        _move_black_king = {{?e, 8}, {?e, 7}},
        _move_white_rook = {{?a, 1}, {?a, 2}},
        _move_black_king_back = {{?e, 7}, {?e, 8}},
        _move_white_rook_back = {{?a, 2}, {?a, 1}}
      ]

      assert {:ok, new_state} = chain_moves(state, moves)
      try_black_king_side_castle = {{?e, 8}, {?g, 8}}
      assert {:error, _} = chain_moves(new_state, [try_black_king_side_castle])
    end

    test "Cannot castle if rook already moved", %{board: board} do
      state = GameState.new(board: board, player: :white)

      moves = [
        _move_white_rook = {{?h, 1}, {?h, 2}}, 
        _move_black_king = {{?e, 8}, {?d, 8}}, 
        _move_white_rook_back = {{?h, 2}, {?h, 1}}, 
        _move_black_king_back = {{?d, 8}, {?e, 8}}
      ]

      assert {:ok, new_state} = chain_moves(state, moves)
      try_white_king_side_castle = {{?e, 1}, {?g, 1}}
      assert {:error, _} = chain_moves(new_state, [try_white_king_side_castle])
    end
  end
end
