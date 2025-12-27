defmodule Chess.Game.Move do
  require Logger
  alias Chess.Game.Validator.PossibleMoves
  use Chess.Game.Helper
  alias Chess.Game.Validator.MoveValidator

  @moduledoc """
  It might be a good idea to implement chess game moves, validation, board
  using graphs and graph algos?
  """

  @spec make_move(Action.t()) :: T.result(GameState.t())
  def make_move(action) do
    with :ok <- MoveValidator.validate(action),
         new_state <- update_game(action) do
      {:ok, new_state}
    else
      {:error, message} ->
        Logger.debug("Unable to make move: " <> message)
        {:error, message}
    end
  end

  @spec update_game(Action.t()) :: GameState.t()
  defp update_game(action) do
    with board <- update_board(action),
         props <- update_props(action),
         state <- %GameState{board: board, props: props},
         {moves, checks} <- PossibleMoves.possible_moves(state) do
      %GameState{state | possible_moves: moves, checks: checks}
    end
  end

  @spec update_board(Action.t()) :: T.board()
  defp update_board(
         action = %Action{
           game_state: %GameState{board: board}
         }
       ) do
    board
    |> do_normal_board_update(action)
    |> remove_en_passant_pawn(action)
    |> promote_pawn(action)
    |> move_castling_rook(action)
  end

  @spec do_normal_board_update(T.board(), Action.t()) :: T.board()
  defp do_normal_board_update(board, %Action{
         move: {origin, target}
       }) do
    board
    |> Map.put(target, Map.get(board, origin))
    |> Map.delete(origin)
  end

  @spec remove_en_passant_pawn(T.board(), Action.t()) :: T.board()
  defp remove_en_passant_pawn(board, %Action{
         game_state: %GameState{props: props}
       }) do
    case Map.get(props, :active_en_passant) do
      nil ->
        board

      {en_passant_pawn, _en_passant_target} ->
        Map.delete(board, en_passant_pawn)
    end
  end

  @spec promote_pawn(T.board(), Action.t()) :: T.board()
  defp promote_pawn(board, %Action{
         move: {_origin, target},
         params: params
       }) do
    case Map.get(params, :pawn_promotion) do
      nil ->
        board

      kind ->
        color = Map.get(params, :player)
        Map.put(board, target, {color, kind})
    end
  end

  @spec move_castling_rook(T.board(), Action.t()) :: T.board()
  defp move_castling_rook(board, %Action{
         move: {origin = {f1, _r1}, target = {f2, _r2}}
       }) do
    piece = Map.get(board, origin)

    rook_castling_move =
      case {piece, abs(f2 - f1), target} do
        {{_, kind}, _, _} when kind != :king ->
          nil

        {_, f, _} when f != 2 ->
          nil

        {_, _, t} ->
          case t do
            {?g, 1} -> {{?h, 1}, {?f, 1}}
            {?c, 1} -> {{?a, 1}, {?d, 1}}
            {?g, 8} -> {{?h, 8}, {?f, 8}}
            {?c, 8} -> {{?a, 8}, {?d, 8}}
            _ -> nil
          end
      end

    case rook_castling_move do
      nil ->
        board

      {rook_origin, rook_target} ->
        board
        |> Map.put(rook_target, Map.get(board, rook_origin))
        |> Map.delete(rook_origin)
    end
  end

  @spec update_props(Action.t()) :: Props.t()
  defp update_props(action = %Action{game_state: %GameState{props: props}}) do
    props
    |> update_player()
    |> update_active_en_passant(action)
    |> update_castling_props(action)
    |> update_king_prop(action)
  end

  @spec update_player(Props.t()) :: Props.t()
  defp update_player(props) do
    Map.update!(props, :player, &Utils.other_player(&1))
  end

  @spec update_active_en_passant(Props.t(), Action.t()) :: Props.t()
  defp update_active_en_passant(
         props,
         %Action{
           game_state: %GameState{board: board},
           move: {origin = {f1, r1}, target = {f2, r2}}
         }
       ) do
    piece = Map.get(board, origin)

    active_en_passant =
      case {f2 - f1, r2 - r1, piece} do
        {0, 2, {:white, :pawn}} -> {target, {f1, r1 + 1}}
        {0, -2, {:black, :pawn}} -> {target, {f1, r1 - 1}}
        _ -> nil
      end

    Map.put(props, :active_en_passant, active_en_passant)
  end

  @spec update_castling_props(Props.t(), Action.t()) :: Props.t()
  defp update_castling_props(props, %Action{
         move: {origin, _target}
       }) do
    case get_castling_prop_key(origin) do
      nil -> props
      key -> Map.put(props, key, true)
    end
  end

  @spec get_castling_prop_key(T.cell()) :: atom()
  defp get_castling_prop_key(origin) do
    case origin do
      {?e, 1} -> :white_king_moved
      {?e, 8} -> :black_king_moved
      {?a, 1} -> :a1_rook_moved
      {?h, 1} -> :h1_rook_moved
      {?a, 8} -> :a8_rook_moved
      {?h, 8} -> :h8_rook_moved
      _ -> nil
    end
  end

  @spec update_king_prop(Props.t(), Action.t()) :: Props.t()
  defp update_king_prop(props, %Action{
         game_state: %GameState{board: board},
         move: {origin, target}
       }) do
    case Map.get(board, origin) do
      {:white, :king} -> Map.put(props, :white_king, target)
      {:black, :king} -> Map.put(props, :black_king, target)
      _ -> props
    end
  end
end
