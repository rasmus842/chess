defmodule Chess.Game.Validator.CorrectPlayer do
  @behaviour Chess.Game.Validator.Spec
  alias Chess.Game.Props

  @impl true
  def validate(
        _action = {
          _game_state = {%Props{player: current_player}, _board},
          _move,
          player
        }
      ) do
    if player == current_player do
      :ok
    else
      {:error, "It is #{current_player}'s turn, not #{player}"}
    end
  end
end
