defmodule Chess.Game.Move do
  require Logger
  use Chess.Game.Types
  alias Chess.Game.Utils
  alias Chess.Game.Props
  alias Chess.Game.Validator.MoveValidator

  @spec make_move(game_action()) :: {:ok, game_state()} | error()
  def make_move(
        action = {
          _game_state = {properties, board},
          _move = {current, target},
          _player
        }
      ) do
    with :ok <- MoveValidator.validate(action),
         current_piece <- Map.get(board, current),
         next_player <- Utils.other_player(properties.player),
         new_props <- %Props{properties | player: next_player},
         new_board <-
           board
           |> Map.put(target, current_piece)
           |> Map.put(current, nil),
         new_state = {new_props, new_board} do
      {:ok, new_state}
    else
      {:error, message} ->
        Logger.debug("Unable to make make: " <> message)
        {:error, message}

      err ->
        Logger.error("Unexpected error: #{inspect(err)}")
        {:error, "Unexpected error"}
    end
  end
end
