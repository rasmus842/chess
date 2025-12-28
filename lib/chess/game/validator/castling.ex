defmodule Chess.Game.Validator.Castling do
  use Chess.Game.Helper

  @spec possible_castling_targets(GameState.t(), T.attacks()) :: T.cells()
  def possible_castling_targets(
        game_state = %GameState{props: props},
        all_attackers
      ) do
    possible_castling_moves(game_state)
    |> Enum.reject(fn {_, rook_prop} -> Map.get(props, rook_prop, true) end)
    |> Enum.reject(fn {move, _} ->
      castling_obstructed?(game_state, move) or
        castling_path_attacked?(game_state, all_attackers, move)
    end)
    |> Enum.map(fn {{_origin, target}, _} -> target end)
    |> MapSet.new()
  end

  defp possible_castling_moves(%GameState{
         props: %Props{player: :white, white_king: wk = {?e, 1}, white_king_moved: false}
       }) do
    [
      {{wk, {?c, 1}}, :a1_rook_moved},
      {{wk, {?g, 1}}, :h1_rook_moved}
    ]
  end

  defp possible_castling_moves(%GameState{
         props: %Props{player: :black, black_king: bk = {?e, 8}, black_king_moved: false}
       }) do
    [
      {{bk, {?c, 8}}, :a8_rook_moved},
      {{bk, {?g, 8}}, :h8_rook_moved}
    ]
  end

  defp possible_castling_moves(_), do: []

  defp castling_obstructed?(%GameState{board: board}, move) do
    cells =
      case move do
        {{?e, 1}, {?c, 1}} -> [{?d, 1}, {?c, 1}, {?b, 1}]
        {{?e, 1}, {?g, 1}} -> [{?f, 1}, {?g, 1}]
        {{?e, 8}, {?c, 8}} -> [{?d, 8}, {?c, 8}, {?b, 8}]
        {{?e, 8}, {?g, 8}} -> [{?f, 8}, {?g, 8}]
      end

    Enum.any?(cells, &Map.get(board, &1))
  end

  defp castling_path_attacked?(
         %GameState{board: board, props: %Props{player: player}},
         all_attackers,
         move
       ) do
    opponent = Utils.other_player(player)

    Utils.get_path(move)
    |> Enum.any?(fn cell ->
      Map.get(all_attackers, cell, [])
      |> Enum.any?(fn attacker ->
        case Map.get(board, attacker) do
          {^opponent, _} -> true
          _ -> false
        end
      end)
    end)
  end
end
