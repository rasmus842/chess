defmodule Chess.Game.Validator.Spec do
  use Chess.Game.Helper

  @callback validate(Action.t()) :: T.result()
end
