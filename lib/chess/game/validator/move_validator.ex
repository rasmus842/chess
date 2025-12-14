defmodule Chess.Game.Validator.MoveValidator do
  @behaviour Chess.Game.Validator.Spec
  use Chess.Game.Types
  alias Chess.Game.Action
  alias Chess.Game.Utils
  alias Chess.Game.Validator.CorrectColors
  alias Chess.Game.Validator.CorrectPlayer
  alias Chess.Game.Validator.PossibleMoves

  @impl true
  def validate(
        action = %Action{
          game_state: _game_state = {_props, board},
          move: _move = {origin, _target}
        }
      ) do
    with :ok <- CorrectPlayer.validate(action),
         :ok <- validate_moves_in_bounds(action),
         :ok <- validate_piece_exists(board, origin),
         :ok <- CorrectColors.validate(action),
         :ok <- validate_move_possible(action),
         :ok <- validate_pawn_promotion(action) do
      :ok
    else
      err -> err
    end
  end

  @spec validate_moves_in_bounds(Action.t()) :: :ok | error()
  defp validate_moves_in_bounds(%Action{
         move: move
       }) do
    if Utils.move_in_bounds?(move) do
      :ok
    else
      {:error, "Move not in bounds"}
    end
  end

  defp validate_piece_exists(board, origin) do
    case Map.get(board, origin) do
      nil -> {:error, "No piece exists at #{Utils.cell_to_string(origin)}"}
      _ -> :ok
    end
  end

  @spec validate_path(Action.t()) :: :ok | error()
  def validate_path(%Action{
        game_state: {_props, board},
        move: move
      }) do
    path = Utils.get_path(move)

    if Utils.path_obstructed?(board, path) do
      {:error, "Path is obstructed"}
    else
      :ok
    end
  end

  @spec validate_move_possible(Action.t()) :: :ok | error()
  defp validate_move_possible(%Action{
         game_state: game_state,
         move: {origin, target}
       }) do
    with possible_moves <- PossibleMoves.possible_moves(game_state),
         {:ok, targets} <- Map.fetch(possible_moves, origin),
         true <- target in targets do
      :ok
    else
      _ -> {:error, "Move not possible"}
    end
  end

  @spec validate_pawn_promotion(Action.t()) :: :ok | error()
  defp validate_pawn_promotion(%Action{
         game_state: {_props, board},
         move: {origin, _target = {_f, r}},
         params: params
       }) do
    piece = Map.get(board, origin)
    pawn_promotion = Map.get(params, :pawn_promotion)

    case {piece, pawn_promotion, r} do
      {{color, :pawn}, kind, r}
      when (color == :white and r == 8) or (color == :black and r == 1) ->
        cond do
          is_nil(kind) ->
            {:error,
             "Please provide kind that pawn is promoted to. Must promote to either knight, rook, bishop, or queen."}

          kind not in [:knight, :rook, :bishop, :queen] ->
            {:error,
             "Invalid kind=#{kind}. Must promote to either knight, rook, bishop, or queen."}

          true ->
            :ok
        end

      _ ->
        :ok
    end
  end
end
