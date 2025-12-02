defmodule Chess.Game.Move do
  use Chess.Game.Types
  alias Chess.Game.Utils
  require Logger
  alias Chess.Game.Props

  @spec make_move(game_action()) :: {:ok, game_state()} | error()
  def make_move(
        action = {
          _game_state = {properties, board},
          _move = {current, target},
          _player
        }
      ) do
    with :ok <- validate_move(action),
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

  @spec validate_move(game_action()) :: :ok | error()
  def validate_move(_), do: :ok

  def validate_move(action = {game_state, move, player}) do
    #  with :ok <- validate_moving_pieces(action) do
    #    :ok
    #  else
    #    err -> err
    #  end
  end

  @spec validate_player(game_action()) :: :ok | error()

  def validate_player(
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

  def validate_player(_), do: :ok

  @spec validate_moving_pieces(game_action()) :: :ok | error()
  def validate_moving_pieces(
        _action = {
          _game_state = {%Props{player: current_player}, board},
          _move = {current, target},
          player
        }
      )
      when player == current_player do
    current_piece = Map.get(board, current)
    target_piece = Map.get(board, target)

    case {current_piece, target_piece} do
      {nil, _} ->
        {:error, "Tile #{Utils.cell_to_string(current)} does not have a piece"}

      {{color, _kind}, _} when color != player ->
        {:error, "Cannot move other player's piece"}

      {_, {color, _kind}} when color == player ->
        {:error, "Cannot take player's own piece"}

        :ok
    end
  end

  def validate_moving_pieces(_), do: :ok
end
