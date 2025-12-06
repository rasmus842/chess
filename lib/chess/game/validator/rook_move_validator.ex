defmodule Chess.Game.Validator.RookMoveValidator do
  @behaviour Chess.Game.Validator.Spec
  use Chess.Game.Types
  alias Chess.Game.Action
  alias Chess.Game.Validator.MoveValidator

  @impl true
  def validate(action) do
    with :ok <- MoveValidator.validate_path(action),
         :ok <- validate_rook_move(action) do
      :ok
    else
      err -> err
    end
  end

  @spec validate_rook_move(Action.t()) :: :ok | error()
  defp validate_rook_move(%Action{
         move: {_current = {f1, r1}, _target = {f2, r2}}
       }) do
    case {abs(f2 - f1), abs(r2 - r1)} do
      {0, r} when r > 0 ->
        :ok

      {f, 0} when f > 0 ->
        :ok

      _ ->
        {:error, "Invalid rook move"}
    end
  end
end
