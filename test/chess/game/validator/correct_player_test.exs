defmodule Chess.Game.Validator.CorrectPlayerTest do
  use ExUnit.Case, async: true
  alias Chess.Game.Props
  alias Chess.Game.Validator.CorrectPlayer

  setup do
    board = %{
      {?a, 2} => {:white, :pawn},
      {?a, 7} => {:black, :pawn}
    }

    {:ok, %{board: board}}
  end

  test "Wrong player", %{board: board} do
    state = {%Props{player: :white}, board}
    move = {{?a, 2}, {?a, 3}}
    assert {:error, _message} = CorrectPlayer.validate({state, move, :black})
  end

  test "Correct player", %{board: board} do
    state = {%Props{player: :white}, board}
    move = {{?a, 2}, {?a, 3}}
    assert :ok = CorrectPlayer.validate({state, move, :white})
  end
end
