defmodule Chess.Game.Validator.MoveValidator do
  @behaviour Chess.Game.Validator.Spec
  alias Chess.Game.Validator.CorrectColors
  alias Chess.Game.Validator.CorrectPlayer

  @impl true
  def validate(action) do
    with :ok <- CorrectPlayer.validate(action),
         :ok <- CorrectColors.validate(action) do
      :ok
    else
      err -> err
    end
  end
end
