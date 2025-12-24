defmodule Chess.Game.Helper do
  defmacro __using__(_opts) do
    quote do
      alias Chess.Game.Types, as: T
      alias Chess.Game.Props
      alias Chess.Game.GameState
      alias Chess.Game.Action
      alias Chess.Game.Utils
    end
  end
end
