defmodule Chess.Game.Validator.CorrectPlayer do
  @behaviour Chess.Game.Validator.Spec
  alias Chess.Game.Props
  alias Chess.Game.Action

  @impl true
  def validate(%Action{
        game_state: {%Props{player: current_player}, _board},
        params: %{player: player}
      }) do
    if player == current_player do
      :ok
    else
      {:error, "It is #{current_player}'s turn, not #{player}"}
    end
  end
end
