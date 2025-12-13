defmodule Chess.Game.Validator.PawnMoveValidator do
  @behaviour Chess.Game.Validator.Spec
  use Chess.Game.Types
  alias Chess.Game.Action
  alias Chess.Game.Props
  alias Chess.Game.Validator.MoveValidator

  @impl true
  def validate(action) do
    with :ok <- MoveValidator.validate_path(action),
         :ok <- validate_pawn_move(action),
         :ok <- validate_promotion(action) do
      :ok
    else
      err -> err
    end
  end

  @spec validate_pawn_move(Action.t()) :: :ok | error()
  defp validate_pawn_move(%Action{
         game_state: {props, board},
         move: {current = {f1, r1}, target = {f2, r2}}
       }) do
    current_piece = Map.get(board, current)
    target_piece = Map.get(board, target)
    diff = {f2 - f1, r2 - r1}

    en_passant? =
      case Map.get(props, :active_en_passant) do
        {_pawn, en_passant_target} -> target == en_passant_target
        nil -> false
      end

    case {current_piece, target_piece, diff} do
      {{_, kind}, _, _} when kind != :pawn ->
        {:error, "Tried to validate #{kind} using pawn validator"}

      {{:white, _}, {:black, _}, {f, r}} when abs(f) == 1 and r == 1 ->
        :ok

      {{:white, _}, nil, {f, r}}
      when en_passant? and abs(f) == 1 and r == 1 ->
        :ok

      {{:black, _}, {:white, _}, {f, r}} when abs(f) == 1 and r == -1 ->
        :ok

      {{:black, _}, nil, {f, r}}
      when en_passant? and abs(f) == 1 and r == -1 ->
        :ok

      {{:white, _}, nil, {f, r}} when f == 0 and r == 1 ->
        :ok

      {{:white, _}, nil, {f, r}} when f == 0 and r == 2 and r1 == 2 ->
        :ok

      {{:black, _}, nil, {f, r}} when f == 0 and r == -1 ->
        :ok

      {{:black, _}, nil, {f, r}} when f == 0 and r == -2 and r1 == 7 ->
        :ok

      _ ->
        {:error, "Invalid pawn move"}
    end
  end

  @spec validate_promotion(Action.t()) :: :ok | error()
  defp validate_promotion(action = %Action{
         params: %{pawn_promotion: kind}
       }) do
    with :ok <- validate_promotion_kind(kind),
         :ok <- validate_promotion_move(action) do
      :ok
    else
      err -> err
    end
  end

  defp validate_promotion(_action), do: :ok

  @spec validate_promotion_kind(term()) :: :ok | error()
  defp validate_promotion_kind(kind) do
    if kind not in [:queen, :rook, :bishop, :knight] do
      {:error,
       "Invalid pawn promotion: Tried to promote to #{kind}, but can promote to queen, rook, bishop, or knight"}
    else
      :ok
    end
  end

  @spec validate_promotion_move(Action.t()) :: :ok | error()
  defp validate_promotion_move(%Action{
         game_state: {_props, board},
         move: {origin, _target = {_f2, r2}}
       }) do
    {color, :pawn} = Map.get(board, origin)

    case {color, r2} do
      {:white, 8} -> :ok
      {:black, 1} -> :ok
      _ -> {:error, "Invalid pawn promotion: pawn has not reached the final rank"}
    end
  end
end
