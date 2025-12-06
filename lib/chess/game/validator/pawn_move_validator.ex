defmodule Chess.Game.Validator.PawnMoveValidator do
  @behaviour Chess.Game.Validator.Spec
  alias Chess.Game.Props
  alias Chess.Game.Utils

  @impl true
  def validate(
        action = {
          _game_state = {props, board},
          _move = {current = {f1, r1}, target = {f2, r2}},
          _player
        }
      ) do
    current_piece = Map.get(board, current)
    target_piece = Map.get(board, target)
    diff = {f2 - f1, r2 - r1}

    case {current_piece, target_piece, diff} do
      {nil, _, _} ->
        {:error, "No piece exist in current tile"}

      {{_, kind}, _, _} when kind != :pawn ->
        raise "Tried to validate #{kind} using pawn validator"

      {_, nil, {f, _}} when f != 0 ->
        {:error, "Pawn cannot change file if not taking"}

      {{:white, _}, {:black, _}, {f, r}} when abs(f) == 1 and r == 1 ->
        :ok

      {{:black, _}, {:white, _}, {f, r}} when abs(f) == 1 and r == -1 ->
        :ok

      {{:white, _}, nil, {_, r}} when r == 1 ->
        :ok

      {{:white, _}, nil, {_, r}} when r == 2 and r1 == 2 ->
        :ok

      {{:black, _}, nil, {_, r}} when r == -1 ->
        :ok

      {{:black, _}, nil, {_, r}} when r == -2 and r1 == 7 ->
        :ok

      _ ->
        {:error, "Invalid pawn move"}
    end
  end
end
