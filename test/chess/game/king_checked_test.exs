defmodule Chess.Game.KingCheckedTest do
  use Chess.Game.MoveCase

  @test_board %{
    {?d, 1} => {:white, :king},
    {?d, 4} => {:white, :bishop},
    {?a, 1} => {:black, :king},
    {?c, 4} => {:black, :rook}
  }

  @two_checks Map.put(@test_board, {?a, 4}, {:white, :rook})

  @pawn_attacks_king_escape_square Map.put(@test_board, {?f, 2}, {:black, :pawn})

  describe "Single check" do
    test "King escapes check" do
      assert_move_is_ok(@test_board, {{?a, 1}, {?b, 1}})
    end

    test "Take the checker" do
      assert_move_is_ok(@test_board, {{?c, 4}, {?d, 4}})
    end

    test "Block the checker" do
      assert_move_is_ok(@test_board, {{?c, 4}, {?c, 3}})
    end

    test "Cannot make move that does not remove check 1" do
      assert_move_is_error(@test_board, {{?c, 4}, {?c, 1}})
    end

    test "Cannot make move that does not remove check 2" do
      assert_move_is_error(@test_board, {{?a, 1}, {?b, 2}})
    end
  end

  describe "More than one checking piece" do
    test "Cannot block if checked by more than one piece" do
      assert_move_is_error(@two_checks, {{?c, 4}, {?c, 3}})
    end

    test "Cannot take checked if another checker exists" do
      assert_move_is_error(@two_checks, {{?c, 4}, {?d, 4}})
    end

    test "King can escape if checked by more than one piece" do
      assert_move_is_ok(@two_checks, {{?a, 1}, {?b, 1}})
    end
  end

  test "King cannot escape to square attacked by pawn" do
    assert_move_is_error(@pawn_attacks_king_escape_square, {{?d, 1}, {?f, 1}})
  end
end
