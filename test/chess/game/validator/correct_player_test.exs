defmodule Chess.Game.Validator.CorrectPlayerTest do
  use ExUnit.Case, async: true
  alias Chess.Game.Props
  alias Chess.Game.Action
  alias Chess.Game.Validator.CorrectPlayer

  setup do
    board = %{
      {?a, 2} => {:white, :pawn},
      {?a, 7} => {:black, :pawn}
    }

    {:ok, %{board: board}}
  end

  test "Wrong player", %{board: board} do
    action = %Action{
      game_state: {%Props{player: :white}, board},
      move: {{?a, 2}, {?a, 3}},
      params: %{player: :black}
    }

    assert {:error, _message} = CorrectPlayer.validate(action)
  end

  test "Correct player", %{board: board} do
    action = %Action{
      game_state: {%Props{player: :white}, board},
      move: {{?a, 2}, {?a, 3}},
      params: %{player: :white}
    }

    assert :ok = CorrectPlayer.validate(action)
  end
end
