defmodule Chess.Game.Validator.Spec do
  use Chess.Game.Types
  alias Chess.Game.Action

  @callback validate(Action.t()) :: :ok | error()
end
