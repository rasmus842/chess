defmodule Chess.Game.Validator.KnightMoveValidator do
  @behaviour Chess.Game.Validator.Spec
  use Chess.Game.Types
  alias Chess.Game.Action

  @impl true
  def validate(%Action{
        move: {_current = {f1, r1}, _target = {f2, r2}}
      }) do
    case {abs(f2 - f1), abs(r2 - r1)} do
      {1, 2} ->
        :ok

      {2, 1} ->
        :ok

      _ ->
        {:error, "Invalid knight move"}
    end
  end
end
