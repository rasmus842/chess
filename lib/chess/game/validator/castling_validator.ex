defmodule Chess.Game.Validator.CastlingValidator do
  @behaviour Chess.Game.Validator.Spec
  use Chess.Game.Helper

  @impl true
  def validate(
        action = %Action{
          game_state: %GameState{board: board},
          move: {origin = {f1, r1}, _target = {f2, r2}}
        }
      ) do
    piece = Map.get(board, origin)
    diff = {f2 - f1, r2 - r1}

    case {piece, diff} do
      {{_, kind}, _} when kind != :king -> :ok
      {_, {f, r}} when abs(f) != 2 or r != 0 -> :ok
      _ -> validate_castling(action)
    end
  end

  @spec validate_castling(Action.t()) :: T.result()
  defp validate_castling(action) do
    with :ok <- validate_castling_path(action),
         :ok <- validate_castling_king(action),
         :ok <- validate_castling_rook(action),
         :ok <- validate_castling_props(action) do
      :ok
    else
      err -> err
    end
  end

  @spec validate_castling_path(Action.t()) :: T.result()
  defp validate_castling_path(%Action{
         game_state: %GameState{board: _board, props: _props},
         move: move = {_origin, _target}
       }) do
    # TODO
    _path =
      case move do
        {{?e, 1}, {?f, 1}} -> :ok
      end
  end

  @spec validate_castling_king(Action.t()) :: T.result()
  defp validate_castling_king(%Action{
         game_state: %GameState{board: board},
         move: {origin, _target}
       }) do
    piece = Map.get(board, origin)

    case {piece, origin} do
      {{:white, :king}, {?e, 1}} -> :ok
      {{:black, :king}, {?e, 8}} -> :ok
      _ -> {:error, "Castling not possible, king not at starting square"}
    end
  end

  @spec validate_castling_rook(Action.t()) :: T.result()
  defp validate_castling_rook(%Action{
         game_state: %GameState{board: board},
         move: {origin, target}
       }) do
    pos =
      case target do
        {?g, 1} -> {?h, 1}
        {?c, 1} -> {?a, 1}
        {?g, 8} -> {?h, 8}
        {?c, 8} -> {?a, 8}
      end

    rook = Map.get(board, pos)
    king = Map.get(board, origin)

    case {king, rook} do
      {{c1, :king}, {c2, :rook}} when c1 == c2 -> :ok
      _ -> {:error, "Castling not possible, rook does not exist at castling square"}
    end
  end

  @spec validate_castling_props(Action.t()) :: T.result()
  defp validate_castling_props(%Action{
         game_state: %GameState{board: board, props: props},
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
