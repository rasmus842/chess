defmodule Chess.Game.Validator.KingMoveValidator do
  @behaviour Chess.Game.Validator.Spec
  use Chess.Game.Types
  alias Chess.Game.Action
  alias Chess.Game.Validator.MoveValidator

  @impl true
  def validate(
        action = %Action{
          move: {_current = {f1, r1}, _target = {f2, r2}}
        }
      ) do
    case {abs(f2 - f1), abs(r2 - r1)} do
      {1, 0} ->
        :ok

      {0, 1} ->
        :ok

      {1, 1} ->
        :ok

      {2, 0} ->
        validate_castling(action)

      _ ->
        {:error, "Invalid king move"}
    end
  end

  @spec validate_castling(Action.t()) :: :ok | error()

  defp validate_castling(action) do
    with :ok <- MoveValidator.validate_path(action),
         :ok <- validate_castling_king(action),
         :ok <- validate_castling_rook(action),
         :ok <- validate_castling_props(action) do
      :ok
    else
      err -> err
    end
  end

  @spec validate_castling_king(Action.t()) :: :ok | error()
  defp validate_castling_king(%Action{
         game_state: {_props, board},
         move: {origin, _target}
       }) do
    piece = Map.get(board, origin)

    case {piece, origin} do
      {{:white, :king}, {?e, 1}} -> :ok
      {{:black, :king}, {?e, 8}} -> :ok
      _ -> {:error, "Castling not possible, king not at starting square"}
    end
  end

  @spec validate_castling_rook(Action.t()) :: :ok | error()
  defp validate_castling_rook(%Action{
         game_state: {_props, board},
         move: {origin, target}
       }) do
    pos =
      case target do
        {?g, 1} -> {?h, 1}
        {?c, 1} -> {?a, 1}
        {?g, 8} -> {?h, 8}
        {?c, 8} -> {?a, 8}
      end

    piece = Map.get(board, pos)
    king = Map.get(board, origin)

    case {king, piece} do
      {{c1, :king}, {c2, :rook}} when c1 == c2 -> :ok
      _ -> {:error, "Castling not possible, rook does not exist at castling square"}
    end
  end

  @spec validate_castling_props(Action.t()) :: :ok | error()
  defp validate_castling_props(%Action{
         game_state: {props, board},
         move: {origin, target}
       }) do
    piece = Map.get(board, origin)

    castling_props =
      case {piece, origin, target} do
        {{:white, :king}, {?e, 1}, {?c, 1}} -> [:white_king_moved, :a1_rook_moved]
        {{:white, :king}, {?e, 1}, {?g, 1}} -> [:white_king_moved, :h1_rook_moved]
        {{:black, :king}, {?e, 8}, {?c, 8}} -> [:black_king_moved, :a8_rook_moved]
        {{:black, :king}, {?e, 8}, {?g, 8}} -> [:black_king_moved, :h8_rook_moved]
      end

    if Enum.any?(castling_props, &Map.get(props, &1)) do
      {:error, "Castling not possible, king or rook already moved"}
    else
      :ok
    end
  end
end
