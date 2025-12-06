defmodule Chess.Game.Validator.PawnMoveValidator do
  @behaviour Chess.Game.Validator.Spec
  alias Chess.Game.Action

  @impl true
  def validate(%Action{
        game_state: {props, board},
        move: {current = {f1, r1}, target = {f2, r2}}
      }) do
    current_piece = Map.get(board, current)
    target_piece = Map.get(board, target)
    diff = {f2 - f1, r2 - r1}

    en_passant? = target == Map.get(props, :en_passant_cell)

    case {current_piece, target_piece, diff} do
      {{_, kind}, _, _} when kind != :pawn ->
        raise "Tried to validate #{kind} using pawn validator"

      {{:white, _}, {:black, _}, {f, r}} when abs(f) == 1 and r == 1 ->
        :ok

      {{:white, _}, nil, {f, r}}
      when en_passant? and abs(f) == 1 and r == 1 ->
        :ok

      {{:black, _}, {:white, _}, {f, r}} when abs(f) == 1 and r == -1 ->
        :ok

      {{:black, _}, nil, {f, r}}
      when en_passant? and abs(f) == 1 and r == -1 ->
        :ok

      {{:white, _}, nil, {f, r}} when f == 0 and r == 1 ->
        :ok

      {{:white, _}, nil, {f, r}} when f == 0 and r == 2 and r1 == 2 ->
        :ok

      {{:black, _}, nil, {f, r}} when f == 0 and r == -1 ->
        :ok

      {{:black, _}, nil, {f, r}} when f == 0 and r == -2 and r1 == 7 ->
        :ok

      _ ->
        {:error, "Invalid pawn move"}
    end
  end
end
