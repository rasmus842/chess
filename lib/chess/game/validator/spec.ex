defmodule Chess.Game.Validator.Spec do
  use Chess.Game.Types

  @callback validate(game_action()) :: {:ok, game_state()} | error()
end
