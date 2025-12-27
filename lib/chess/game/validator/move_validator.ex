defmodule Chess.Game.Validator.MoveValidator do
  @behaviour Chess.Game.Validator.Spec
  use Chess.Game.Helper
  alias Chess.Game.Validator.CorrectColors
  alias Chess.Game.Validator.CorrectPlayer
  alias Chess.Game.Validator.CastlingValidator

  @impl true
  def validate(action) do
    with :ok <- CorrectPlayer.validate(action),
         :ok <- validate_moves_in_bounds(action),
         :ok <- validate_piece_exists(action),
         :ok <- CorrectColors.validate(action),
         :ok <- validate_move_possible(action),
         :ok <- validate_pawn_promotion(action),
         :ok <- CastlingValidator.validate(action) do
      :ok
    else
      err -> err
    end
  end

  @spec validate_moves_in_bounds(Action.t()) :: T.result()
  defp validate_moves_in_bounds(%Action{
         move: move
       }) do
    if Utils.move_in_bounds?(move) do
      :ok
    else
      {:error, "Move not in bounds"}
    end
  end

  defp validate_piece_exists(%Action{
         game_state: %GameState{board: board},
         move: {origin, _target}
       }) do
    case Map.get(board, origin) do
      nil -> {:error, "No piece exists at #{Utils.cell_to_string(origin)}"}
      _ -> :ok
    end
  end

  @spec validate_move_possible(Action.t()) :: T.result()
  defp validate_move_possible(%Action{
         game_state: %GameState{possible_moves: possible_moves},
         move: {origin, target}
       }) do
    dbg(possible_moves)
    moves = Map.get(possible_moves, origin)

    cond do
      is_nil(moves) or not Enum.member?(moves, target) ->
        {:error, "Move not possible"}

      true ->
        :ok
    end
  end

  @spec validate_pawn_promotion(Action.t()) :: T.result()
  defp validate_pawn_promotion(%Action{
         game_state: %GameState{board: board},
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
