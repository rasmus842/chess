defmodule Chess.Game.Validator.BishopMoveValidator do
  @behaviour Chess.Game.Validator.Spec
  use Chess.Game.Types
  alias Chess.Game.Action
  alias Chess.Game.Validator.MoveValidator

  @impl true
  def validate(action) do
    with :ok <- MoveValidator.validate_path(action),
         :ok <- validate_bishop_move(action) do
      :ok
    else
      err -> err
    end
  end

  @spec validate_bishop_move(Action.t()) :: :ok | error()
  def validate_bishop_move(%Action{
         move: {_current = {f1, r1}, _target = {f2, r2}}
       }) do
    case {abs(f2 - f1), abs(r2 - r1)} do
      {f, r} when f > 0 and r > 0 and f == r ->
        :ok

      _ ->
        {:error, "Invalid bishop move"}
    end
  end
end
