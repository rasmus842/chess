defmodule Chess.Game.Validator.MoveValidator do
  @behaviour Chess.Game.Validator.Spec
  use Chess.Game.Types
  alias Chess.Game.Validator.PawnMoveValidator
  alias Chess.Game.Validator.CorrectColors
  alias Chess.Game.Validator.CorrectPlayer
  alias Chess.Game.Utils

  @impl true
  def validate(
        action = {
          _game_state = {_props, board},
          _move = {origin, _target},
          _player
        }
      ) do
    with :ok <- CorrectPlayer.validate(action),
         :ok <- CorrectColors.validate(action),
         :ok <- validate_piece_exists(board, origin),
         :ok <- validate_path(action),
         {:ok, piece_validator} <- get_piece_validator(action),
         :ok <- piece_validator.validate(action) do
      :ok
    else
      err -> err
    end
  end

  defp validate_piece_exists(board, origin) do
    case Map.get(board, origin) do
      nil -> {:error, "No piece exists at #{origin}"}
      _ -> :ok
    end
  end

  @spec validate_path(game_action()) :: :ok | error()
  defp validate_path(
         _action = {
           _game_state = {_props, board},
           move = {origin, _target},
           _player
         }
       ) do
    case Map.get(board, origin) do
      {_, :knigth} ->
        :ok

      _ ->
        path = Utils.get_path(board, move)

        if Utils.path_obstructed?(board, path) do
          {:error, "Path is obstructed"}
        else
          :ok
        end
    end
  end

  @spec get_piece_validator(game_action()) :: {:ok, module()} | error()
  defp(
    get_piece_validator(
      _action = {
        _game_state = {_props, board},
        _move = {current, _target},
        _player
      }
    )
  ) do
    case Map.get(board, current) do
      {_, kind} -> {:error, "Missing validator for kind: #{kind}"}
    end
  end
end
