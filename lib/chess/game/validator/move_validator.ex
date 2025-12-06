defmodule Chess.Game.Validator.MoveValidator do
  @behaviour Chess.Game.Validator.Spec
  use Chess.Game.Types
  alias Chess.Game.Action
  alias Chess.Game.Validator.PawnMoveValidator
  alias(Chess.Game.Validator.KnightMoveValidator)
  alias(Chess.Game.Validator.RookMoveValidator)
  alias Chess.Game.Validator.CorrectColors
  alias Chess.Game.Validator.CorrectPlayer
  alias Chess.Game.Utils

  @impl true
  def validate(
        action = %Action{
          game_state: {_props, board},
          move: {origin, _target}
        }
      ) do
    with :ok <- CorrectPlayer.validate(action),
         :ok <- validate_moves_in_bounds(action),
         :ok <- validate_piece_exists(board, origin),
         :ok <- CorrectColors.validate(action),
         {:ok, piece_validator} <- get_piece_validator(action),
         :ok <- piece_validator.validate(action) do
      :ok
    else
      err -> err
    end
  end

  @spec validate_moves_in_bounds(Action.t()) :: :ok | error()
  defp validate_moves_in_bounds(%Action{
         move: move
       }) do
    if Utils.move_in_bounds?(move) do
      :ok
    else
      {:error, "Move not in bounds"}
    end
  end

  defp validate_piece_exists(board, origin) do
    case Map.get(board, origin) do
      nil -> {:error, "No piece exists at #{Utils.cell_to_string(origin)}"}
      _ -> :ok
    end
  end

  @spec validate_path(Action.t()) :: :ok | error()
  def validate_path(%Action{
        game_state: {_props, board},
        move: move
      }) do
    path = Utils.get_path(board, move)

    if Utils.path_obstructed?(board, path) do
      {:error, "Path is obstructed"}
    else
      :ok
    end
  end

  @spec get_piece_validator(Action.t()) :: {:ok, module()} | error()
  defp(
    get_piece_validator(%Action{
      game_state: {_props, board},
      move: {current, _target}
    })
  ) do
    case Map.get(board, current) do
      {_, :pawn} -> {:ok, PawnMoveValidator}
      {_, :knight} -> {:ok, KnightMoveValidator}
      {_, :rook} -> {:ok, RookMoveValidator}
      {_, kind} -> {:error, "Missing validator for kind: #{kind}"}
    end
  end
end
