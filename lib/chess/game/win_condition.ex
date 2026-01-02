defmodule Chess.Game.WinCondition do
  use Chess.Game.Helper

  @spec get_winner(GameState.t()) ::
          {:continue, T.player()}
          | {:check_make, T.player()}
          | {:state_mate}
  def get_winner(%GameState{
        props: %Props{player: player},
        possible_moves: moves,
        checks: checks
      }) do
    cond do
      not Enum.empty?(moves) -> {:continue, player}
      Enum.empty?(checks) -> {:stale_mate}
      true -> {:check_mate, Utils.other_player(player)}
    end
  end
end
