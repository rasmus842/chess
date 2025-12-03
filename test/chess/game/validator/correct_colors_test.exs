defmodule Chess.Game.Validator.CorrectColorsTest do
  use ExUnit.Case, async: true
  alias Chess.Game.Props
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
    state = {%Props{player: :white}, board}
    move = {{?a, 1}, {?a, 7}}
    assert {:error, _message} = CorrectColors.validate({state, move, :white})
  end

  test "Player cannot move another player's piece", %{board: board} do
    state = {%Props{player: :white}, board}
    move = {{?a, 7}, {?a, 2}}
    assert {:error, _message} = CorrectColors.validate({state, move, :white})
  end

  test "Player cannot take his own piece", %{board: board} do
    state = {%Props{player: :white}, board}
    move = {{?a, 2}, {?c, 2}}
    assert {:error, _message} = CorrectColors.validate({state, move, :white})
  end
end
