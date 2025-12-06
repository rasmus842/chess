defmodule Chess.Game.Validator.QueenMoveValidator do
  @behaviour Chess.Game.Validator.Spec
  use Chess.Game.Types
  alias Chess.Game.Action
  alias Chess.Game.Validator.MoveValidator
  alias Chess.Game.Validator.RookMoveValidator
  alias Chess.Game.Validator.BishopMoveValidator

  @impl true
  def validate(action) do
    with :ok <- MoveValidator.validate_path(action),
         :ok <- validate_queen_move(action) do
      :ok
    else
      err -> err
    end
  end

  @spec validate_queen_move(Action.t()) :: :ok | error()
  defp validate_queen_move(action) do
    with {:error, _msg} <- RookMoveValidator.validate_rook_move(action),
         {:error, _msg} <- BishopMoveValidator.validate_bishop_move(action) do
      {:error, "Invalid queen move"}
    else
      :ok -> :ok
    end
  end
end
