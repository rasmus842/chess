defmodule Chess.Game.Validator.PossibleMoves do
  use Chess.Game.Types
  alias Chess.Game.Utils
  alias Chess.Game.Props

  @spec possible_moves(game_state()) :: %{
          optional(cell()) => [cell()]
        }
  def possible_moves(game_state = {_props, board}) do
    board
    |> Enum.reject(fn {_cell, piece} -> piece == nil end)
    |> Enum.map(fn {cell, piece} ->
      {cell, possible_piece_targets(game_state, cell, piece)}
    end)
    |> Map.new()
  end

  @spec possible_piece_targets(game_state(), cell(), piece()) :: [cell()]
  defp possible_piece_targets(game_state, origin, _piece = {_color, kind}) do
    get_targets =
      case kind do
        :king -> &king_possible_targets/2
        :rook -> &rook_possible_targets/2
        :bishop -> &bishop_possible_targets/2
        :queen -> &queen_possible_targets/2
        :knight -> &knight_possible_targets/2
        :pawn -> &pawn_possible_targets/2
      end

    get_targets.(game_state, origin)
  end

  @spec king_possible_targets(game_state(), cell()) :: [cell()]
  defp king_possible_targets(_game_state = {_props, board}, origin) do
    {color, :king} = Map.get(board, origin)

    king_all_targets(origin)
    |> Enum.filter(&Utils.cell_in_bounds?/1)
    |> Enum.reject(&Utils.has_piece(board, &1, color))
  end

  defp king_all_targets(_origin = {f, r}) do
    [
      {f + 1, r + 1},
      {f + 1, r},
      {f + 1, r - 1},
      {f, r + 1},
      {f, r},
      {f, r - 1},
      {f - 1, r + 1},
      {f - 1, r},
      {f - 1, r - 1}
    ]
  end

  @spec king_castling_moves(game_state(), cell()) :: [move()]
  defp king_castling_moves(game_state = {props, board}, origin) do
    {color, :king} = Map.get(board, origin)

    # TODO - filter out castling that is being attacked
    # to do that we must have knowledge on possible moves
    king_castling_moves(game_state, origin, color)
  end

  @spec king_castling_moves(game_state(), cell(), color()) :: [move()]
  defp king_castling_moves(
         _game_state = {props = %Props{white_king_moved: false}, board},
         origin,
         :white
       ) do
    [
      {:a1_rook_moved, {?c, 1}, {?a, 1}},
      {:h1_rook_moved, {?g, 1}, {?h, 1}}
    ]
    |> Enum.filter(fn {prop, _, _} -> Map.get(props, prop) end)
    |> Enum.reject(fn {_, _, rook_cell} ->
      Utils.path_obstructed?(board, {origin, rook_cell})
    end)
    |> Enum.map(fn {_, target, _} -> {origin, target} end)
  end

  defp king_castling_moves(
         _game_state = {props = %Props{black_king_moved: false}, board},
         origin,
         :black
       ) do
    [
      {:a8_rook_moved, {?c, 8}, {?a, 8}},
      {:h8_rook_moved, {?g, 8}, {?h, 8}}
    ]
    |> Enum.filter(fn {prop, _, _} -> Map.get(props, prop) end)
    |> Enum.reject(fn {_, _, rook_cell} ->
      Utils.path_obstructed?(board, {origin, rook_cell})
    end)
    |> Enum.map(fn {_, target, _} -> {origin, target} end)
  end

  defp king_castling_moves(_, _, _), do: []

  @spec rook_possible_targets(game_state(), cell()) :: [cell()]
  defp rook_possible_targets(_game_state = {_props, board}, origin) do
    {color, :rook} = Map.get(board, origin)

    rook_all_targets(origin)
    |> Enum.filter(&Utils.cell_in_bounds?/1)
    |> Enum.reject(&Utils.has_piece(board, &1, color))
    |> Enum.reject(&Utils.move_obstructed?(board, {origin, &1}))
  end

  defp rook_all_targets(origin) do
    [
      &{&1 + 1, &2},
      &{&1 - 1, &2},
      &{&1, &2 + 1},
      &{&1, &2 - 1}
    ]
    |> Enum.flat_map(&Utils.get_path_to_cell(origin, &1))
    |> Enum.reject(&(&1 == origin))
  end

  @spec bishop_possible_targets(game_state(), cell()) :: [cell()]
  defp bishop_possible_targets(_game_state = {_props, board}, origin) do
    {color, :bishop} = Map.get(board, origin)

    bishop_all_targets(origin)
    |> Enum.filter(&Utils.cell_in_bounds?/1)
    |> Enum.reject(&Utils.has_piece(board, &1, color))
    |> Enum.reject(&Utils.move_obstructed?(board, {origin, &1}))
  end

  defp bishop_all_targets(origin) do
    [
      &{&1 + 1, &2 + 1},
      &{&1 + 1, &2 - 1},
      &{&1 - 1, &2 + 1},
      &{&1 - 1, &2 - 1}
    ]
    |> Enum.flat_map(&Utils.get_path_to_cell(origin, &1))
    |> Enum.reject(&(&1 == origin))
  end

  @spec queen_possible_targets(game_state(), cell()) :: [cell()]
  defp queen_possible_targets(_game_state = {_props, board}, origin) do
    {color, :queen} = Map.get(board, origin)

    queen_all_targets(origin)
    |> Enum.filter(&Utils.cell_in_bounds?/1)
    |> Enum.reject(&Utils.has_piece(board, &1, color))
    |> Enum.reject(&Utils.move_obstructed?(board, {origin, &1}))
  end

  defp queen_all_targets(origin) do
    [&bishop_all_targets/1, &rook_all_targets/1]
    |> Enum.flat_map(& &1.(origin))
  end

  @spec knight_possible_targets(game_state(), cell()) :: [cell()]
  defp knight_possible_targets(_game_state = {_props, board}, origin) do
    {color, :knight} = Map.get(board, origin)

    knight_all_targets(origin)
    |> Enum.filter(&Utils.cell_in_bounds?/1)
    |> Enum.reject(&Utils.has_piece(board, &1, color))
  end

  defp knight_all_targets(_origin = {f, r}) do
    [
      {f + 2, r + 1},
      {f + 2, r - 1},
      {f - 2, r + 1},
      {f - 2, r - 1},
      {f + 1, r + 2},
      {f + 1, r - 2},
      {f - 1, r + 2},
      {f - 1, r - 2}
    ]
  end

  @spec pawn_possible_targets(game_state(), cell()) :: [cell()]
  defp pawn_possible_targets(game_state = {_props, board}, origin) do
    {color, :pawn} = Map.get(board, origin)

    pawn_all_targets(origin, color)
    |> Enum.filter(&Utils.cell_in_bounds?/1)
    |> Enum.filter(&pawn_move_possible?(game_state, origin, &1))
  end

  defp pawn_all_targets(_origin = {f, r}, :white) do
    [
      {f, r + 1},
      {f, r + 2},
      {f + 1, r + 1},
      {f - 1, r + 1}
    ]
  end

  defp pawn_all_targets(_origin = {f, r}, :black) do
    [
      {f, r - 1},
      {f, r - 2},
      {f + 1, r - 1},
      {f - 1, r - 1}
    ]
  end

  defp pawn_all_take_targets(_origin = {f, r}, :white) do
    [
      {f + 1, r + 1},
      {f - 1, r + 1}
    ]
  end

  defp pawn_all_take_targets(_origin = {f, r}, :black) do
    [
      {f + 1, r - 1},
      {f - 1, r - 1}
    ]
  end

  defp pawn_move_possible?(
         _game_state = {
           props,
           board
         },
         origin = {f1, r1},
         target = {f2, r2}
       ) do
    {color, :pawn} = Map.get(board, origin)

    case {abs(f2 - f1), abs(r2 - r1)} do
      {0, 1} ->
        Map.get(board, target) == nil

      {0, 2} ->
        ((color == :white and r1 == 2) or
           (color == :black and r1 == 7)) and
          not Utils.move_obstructed?(board, {origin, target}) and
          Map.get(board, target) == nil

      {1, 1} ->
        case Map.get(board, target) do
          {c, _} when c != color ->
            true

          nil ->
            case Map.get(props, :active_en_passant) do
              nil ->
                false

              {_en_passant_pawn, en_passant_target} ->
                target == en_passant_target
            end

          _ ->
            false
        end
    end
  end
end
