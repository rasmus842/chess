defmodule Chess.Game.Validator.PossibleMoves do
  use Chess.Game.Helper
  alias Chess.Game.Validator.Castling

  @typep pinned_piece :: T.cell()
  @typep cells_pinned_to :: T.cells()
  @type pin :: {pinned_piece(), cells_pinned_to()}
  @type pins :: %{optional(pinned_piece()) => cells_pinned_to()}

  @spec possible_moves(GameState.t()) :: {T.targets(), T.attacks()}
  def possible_moves(
        game_state = %GameState{
          board: board,
          props: %Props{player: player, white_king: white_king_cell, black_king: black_king_cell}
        }
      ) do
    pins = get_pins(game_state)
    all_targets = all_targets(game_state)
    all_attackers = possible_attackers(all_targets)

    current_player_king_cell =
      case player do
        :white -> white_king_cell
        :black -> black_king_cell
      end

    checkers =
      case Map.get(all_attackers, current_player_king_cell) do
        nil -> MapSet.new()
        atks -> MapSet.new(atks)
      end

    # king can move to unattacked targets
    king_escape_targets =
      Map.get(all_targets, current_player_king_cell, [])
      |> Enum.reject(fn cell ->
        Map.get(all_attackers, cell)
        |> Enum.map(&Map.get(board, &1))
        |> Enum.any?(fn {col, _} -> col != player end)
      end)
      |> MapSet.new()

    king_castling_targets =
      Castling.possible_castling_targets(game_state, all_attackers)

    king_possible_targets = MapSet.union(king_escape_targets, king_castling_targets)

    possible_targets =
      Map.put(all_targets, current_player_king_cell, king_possible_targets)
      |> Enum.filter(fn {origin, _} ->
        case Map.get(board, origin) do
          {^player, _} -> true
          _ -> false
        end
      end)
      |> Enum.map(fn {origin, targets} ->
        case Map.get(pins, origin) do
          nil -> {origin, targets}
          cells_pinned_to -> {origin, MapSet.intersection(targets, cells_pinned_to)}
        end
      end)
      |> Enum.reject(fn {_origin, targets} ->
        targets == nil or MapSet.size(targets) == 0
      end)
      |> Map.new()

    checks =
      if current_player_king_cell != nil and MapSet.size(checkers) > 0 do
        %{current_player_king_cell => checkers}
      else
        %{}
      end

    possible_moves =
      case MapSet.size(checkers) do
        0 ->
          possible_targets

        c when c > 1 ->
          cond do
            MapSet.size(king_escape_targets) == 0 -> %{}
            true -> %{current_player_king_cell => king_escape_targets}
          end

        1 ->
          [checker] = MapSet.to_list(checkers)

          cells_to_cancel_check =
            case Map.get(board, checker) do
              {_, k} when k in [:pawn, :knight] ->
                # cannot block, can only take
                MapSet.new([checker])

              _ ->
                # include blocking moves aswell
                Utils.get_path({checker, current_player_king_cell})
                |> Enum.reject(&(&1 == current_player_king_cell))
                |> MapSet.new()
            end

          possible_targets
          |> Enum.map(fn {origin, targets} ->
            if origin == current_player_king_cell do
              {origin, MapSet.intersection(targets, king_escape_targets)}
            else
              {origin, MapSet.intersection(targets, cells_to_cancel_check)}
            end
          end)
          |> Enum.reject(fn {_, targets} -> MapSet.size(targets) == 0 end)
          |> Map.new()
      end

    {possible_moves, checks}
  end

  @spec get_pins(GameState.t()) :: pins()
  defp get_pins(
         game_state = %GameState{
           board: board,
           props: props
         }
       ) do
    white_king_cell = Map.get(props, :white_king)
    white_king_piece = Map.get(board, white_king_cell)
    white_piece_pins = get_pins(game_state, white_king_cell, white_king_piece)

    black_king_cell = Map.get(props, :black_king)
    black_king_piece = Map.get(board, black_king_cell)
    black_piece_pins = get_pins(game_state, black_king_cell, black_king_piece)

    Enum.concat(white_piece_pins, black_piece_pins)
    |> Map.new()
  end

  @spec get_pins(GameState.t(), T.cell() | nil, T.piece() | nil) :: pins()
  defp get_pins(_game_state, cell, piece)
       when is_nil(cell) or is_nil(piece) do
    %{}
  end

  defp get_pins(game_state, target, king_piece) do
    rook_or_queen_pinning_attacks =
      rook_paths_to(target)
      |> Enum.map(&to_pin(game_state, &1, king_piece, [:rook, :queen]))

    bishop_or_queen_pinning_attacks =
      bishop_paths_to(target)
      |> Enum.map(&to_pin(game_state, &1, king_piece, [:bishop, :queen]))

    [rook_or_queen_pinning_attacks, bishop_or_queen_pinning_attacks]
    |> Enum.flat_map(& &1)
    |> Enum.reject(&is_nil/1)
  end

  @spec to_pin(GameState.t(), [T.cell()], T.piece(), [T.kind()]) :: pin() | nil
  defp to_pin(
         %GameState{board: board},
         path_to_king,
         king_piece = {color_of_king, :king},
         attack_kinds
       ) do
    opponent_color = Utils.other_player(color_of_king)

    result =
      Enum.reduce(
        path_to_king,
        {[], nil, nil},
        fn cell, {cells, attacker, blocker} ->
          case {Map.get(board, cell), attacker, blocker} do
            {nil, nil, _} ->
              {[], nil, nil}

            {nil, _, _} ->
              {[cell | cells], attacker, blocker}

            {^king_piece, _, _} ->
              {cells, attacker, blocker}

            {{^color_of_king, _k}, _, nil} ->
              {[cell | cells], attacker, cell}

            {{^color_of_king, _k}, _, _} ->
              {[], nil, nil}

            {{^opponent_color, k}, _, _} ->
              cond do
                k in attack_kinds -> {[cell], cell, nil}
                true -> {[], nil, nil}
              end
          end
        end
      )

    case result do
      {cells_pinned_to, pinner, pinned_piece}
      when cells_pinned_to == [] or is_nil(pinner) or is_nil(pinned_piece) ->
        nil

      {cells_pinned_to, _pinner, pinned_piece} ->
        {pinned_piece, MapSet.new(cells_pinned_to)}
    end
  end

  @spec possible_attackers(T.targets()) :: T.attacks()
  defp possible_attackers(possible_targets) do
    Enum.reduce(possible_targets, %{}, fn {attacker, targets}, acc ->
      Enum.reduce(targets, acc, fn target, acc2 ->
        Map.update(acc2, target, MapSet.new([attacker]), &MapSet.put(&1, attacker))
      end)
    end)
  end

  @spec all_targets(GameState.t()) :: T.targets()
  def all_targets(game_state = %GameState{board: board}) do
    board
    |> Enum.reject(fn {_cell, piece} -> piece == nil end)
    |> Enum.map(fn {cell, piece} ->
      {cell, possible_piece_targets(game_state, cell, piece)}
    end)
    |> Map.new()
  end

  @spec possible_piece_targets(GameState.t(), T.cell(), T.piece()) :: T.cells()
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
    |> MapSet.new()
  end

  @spec king_possible_targets(GameState.t(), T.cell()) :: T.cells()
  defp king_possible_targets(%GameState{board: board}, origin) do
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

  @spec rook_possible_targets(GameState.t(), T.cell()) :: [T.cell()]
  defp rook_possible_targets(%GameState{board: board}, origin) do
    {color, :rook} = Map.get(board, origin)

    rook_paths_to(origin)
    |> Enum.flat_map(& &1)
    |> Enum.reject(&Utils.has_piece(board, &1, color))
    |> Enum.reject(&Utils.move_obstructed?(board, {origin, &1}))
  end

  defp rook_paths_to(target) do
    [
      &{&1 + 1, &2},
      &{&1 - 1, &2},
      &{&1, &2 + 1},
      &{&1, &2 - 1}
    ]
    |> Enum.map(&Utils.get_path_to_cell(target, &1))
  end

  @spec bishop_possible_targets(GameState.t(), T.cell()) :: [T.cell()]
  defp bishop_possible_targets(%GameState{board: board}, origin) do
    {color, :bishop} = Map.get(board, origin)

    bishop_paths_to(origin)
    |> Enum.flat_map(& &1)
    |> Enum.reject(&Utils.has_piece(board, &1, color))
    |> Enum.reject(&Utils.move_obstructed?(board, {origin, &1}))
  end

  defp bishop_paths_to(origin) do
    [
      &{&1 + 1, &2 + 1},
      &{&1 + 1, &2 - 1},
      &{&1 - 1, &2 + 1},
      &{&1 - 1, &2 - 1}
    ]
    |> Enum.map(&Utils.get_path_to_cell(origin, &1))
  end

  @spec queen_possible_targets(GameState.t(), T.cell()) :: [T.cell()]
  defp queen_possible_targets(%GameState{board: board}, origin) do
    {color, :queen} = Map.get(board, origin)

    queen_paths_to(origin)
    |> Enum.flat_map(& &1)
    |> Enum.reject(&Utils.has_piece(board, &1, color))
    |> Enum.reject(&Utils.move_obstructed?(board, {origin, &1}))
  end

  defp queen_paths_to(origin) do
    Enum.concat(
      bishop_paths_to(origin),
      rook_paths_to(origin)
    )
  end

  @spec knight_possible_targets(GameState.t(), T.cell()) :: [T.cell()]
  defp knight_possible_targets(%GameState{board: board}, origin) do
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

  @spec pawn_possible_targets(GameState.t(), T.cell()) :: [T.cell()]
  defp pawn_possible_targets(game_state = %GameState{board: board}, origin) do
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

  defp pawn_move_possible?(
         %GameState{board: board, props: props},
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
