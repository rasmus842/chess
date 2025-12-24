defmodule Chess.Game.Validator.CorrectPlayer do
  @behaviour Chess.Game.Validator.Spec
  use Chess.Game.Helper

  @impl true
  def validate(%Action{
        game_state: %GameState{props: %Props{player: current_player}},
        params: %{player: player}
      }) do
    if player == current_player do
      :ok
    else
      {:error, "It is #{current_player}'s turn, not #{player}"}
    end
  end
end
