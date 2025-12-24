defmodule Chess.Game.WinConditionTest do
  use Chess.Game.MoveCase

  describe "Cannot move pinned piece" do
    setup do
      board = %{
        {?e, 1} => {:white, :king},
        {?f, 1} => {:white, :bishop},
        {?e, 2} => {:white, :queen},
        {?d, 1} => {:white, :rook},
        {?f, 2} => {:white, :pawn},
        {?a, 1} => {:black, :rook},
        {?h, 1} => {:black, :queen},
        {?h, 4} => {:black, :bishop},
        {?e, 7} => {:black, :rook}
      }

      {:ok, %{board: board}}
    end

    for {name, move} <- [
          {"Black rook pins white rook", {{?d, 1}, {?d, 4}}},
          {"Black queen pins white bishop", {{?f, 1}, {?h, 3}}},
          {"Black bishop pins white pawn", {{?f, 2}, {?f, 3}}},
          {"Black rook pins white queen", {{?e, 2}, {?d, 3}}}
        ] do
      test name, %{board: board} do
        assert_move_is_error(board, unquote(move))
      end
    end
  end

  # TODO - can move pinned piece, if the other pinning piece is also pinned!

  # TODO - checks

  # TODO - if no more available moves - that means you got mated!
end
