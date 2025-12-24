defmodule Chess.Game.Validator.CorrectColorsTest do
  use ExUnit.Case, async: true
  alias Chess.Game.Props
  alias Chess.Game.GameState
  alias Chess.Game.Action
  alias Chess.Game.Validator.CorrectColors

  setup do
    board = %{
      {?a, 2} => {:white, :rook},
      {?a, 7} => {:black, :rook},
      {?c, 2} => {:white, :pawn}
    }

    {:ok, %{board: board}}
  end

  test "Player cannot move a piece that does not exist", %{board: board} do
    action = %Action{
      game_state: %GameState{board: board, props: %Props{player: :white}},
      move: {{?a, 1}, {?a, 7}},
      params: %{player: :white}
    }

    assert {:error, _message} = CorrectColors.validate(action)
  end

  test "Player cannot move another player's piece", %{board: board} do
    action = %Action{
      game_state: %GameState{board: board, props: %Props{player: :white}},
      move: {{?a, 7}, {?a, 2}},
      params: %{player: :white}
    }

    assert {:error, _message} = CorrectColors.validate(action)
  end

  test "Player cannot take his own piece", %{board: board} do
    action = %Action{
      game_state: %GameState{board: board, props: %Props{player: :white}},
      move: {{?a, 2}, {?c, 2}},
      params: %{player: :white}
    }

    assert {:error, _message} = CorrectColors.validate(action)
  end
end
