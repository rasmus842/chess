defmodule Chess.Game.Validator.CorrectColors do
  @behaviour Chess.Game.Validator.Spec
  alias Chess.Game.Props
  alias Chess.Game.Action
  alias Chess.Game.Utils

  @impl true
  def validate(%Action{
        game_state: {%Props{player: current_player}, board},
        move: {current, target},
        params: %{player: player}
      })
      when player == current_player do
    current_piece = Map.get(board, current)
    target_piece = Map.get(board, target)

    case {current_piece, target_piece} do
      {nil, _} ->
        {:error, "Tile #{Utils.cell_to_string(current)} does not have a piece"}

      {{color, _kind}, _} when color != player ->
        {:error, "Cannot move other player's piece"}

      {_, {target_color, _kind}} when target_color == player ->
        {:error, "Cannot take player's own piece"}

      _ ->
        :ok
    end
  end
end
