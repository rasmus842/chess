defmodule Chess.Game.Move do
  require Logger
  use Chess.Game.Types
  alias Chess.Game.Utils
  alias Chess.Game.Props
  alias Chess.Game.Validator.MoveValidator

  @spec make_move(game_action()) :: {:ok, game_state()} | error()
  def make_move(action) do
    with :ok <- MoveValidator.validate(action),
         new_board <- update_board(action),
         new_props <- update_props(action) do
      {:ok, _new_state = {new_props, new_board}}
    else
      {:error, message} ->
        Logger.debug("Unable to make move: " <> message)
        {:error, message}
    end
  end

  @spec update_board(game_action()) :: board()
  defp update_board(
         _action = {
           _game_state = {_props, board},
           _move = {origin, target},
           _player
         }
       ) do
    board
    |> Map.put(target, Map.get(board, origin))
    |> Map.put(origin, nil)
  end

  @spec update_props(game_action()) :: Props.t()
  defp update_props(
         action = {
           _game_state = {props, _board},
           _move = {_origin, _target},
           _player
         }
       ) do
    props
    |> update_player()
    |> update_en_passant_cell(action)
  end

  @spec update_player(Props.t()) :: Props.t()
  defp update_player(props) do
    Map.update!(props, :player, &Utils.other_player(&1))
  end

  @spec update_en_passant_cell(Props.t(), game_action()) :: Props.t()
  defp update_en_passant_cell(
         props,
         _action = {
           _game_state = {_props, board},
           _move = {origin = {f1, r1}, _target = {f2, r2}},
           _player
         }
       ) do
    piece = Map.get(board, origin)

    en_passant_cell =
      case {f2 - f1, r2 - r1, piece} do
        {0, 2, {:white, :pawn}} -> {f1, r1 + 1}
        {0, -2, {:black, :pawn}} -> {f1, r1 - 1}
        _ -> nil
      end

    Map.put(props, :en_passant_cell, en_passant_cell)
  end
end
