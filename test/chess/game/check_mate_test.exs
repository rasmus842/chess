defmodule Chess.Game.CheckMateTest do
  use Chess.Game.MoveCase
  alias Chess.Game.WinCondition

  @board %{
    {?h, 1} => {:black, :king},
    {?h, 3} => {:white, :queen},
    {?e, 1} => {:white, :king}
  }

  test "Sanity check - could escape check" do
    state = assert_move_is_ok(@board, {{?h, 1}, {?g, 1}})
    assert {:continue, :white} = WinCondition.get_winner(state)
  end

  test "Make check-mating move" do
    state = assert_move_is_ok(@board, {{?e, 1}, {?f, 1}})

    assert %GameState{
             props: %Props{player: :black},
             possible_moves: moves,
             checks: %{{?h, 1} => checkers}
           } =
             state

    assert Enum.empty?(moves)
    assert MapSet.member?(checkers, {?h, 3})

    assert {:error, _} = chain_moves(state, [{{?h, 1}, {?g, 1}}])
    assert {:check_mate, :white} = WinCondition.get_winner(state)
  end

  test "Stale mate" do
    state = assert_move_is_ok(@board, {{?h, 3}, {?g, 3}})

    assert %GameState{
             props: %Props{player: :black},
             possible_moves: moves,
             checks: checks
           } =
             state

    assert Enum.empty?(moves)
    assert Enum.empty?(checks)

    assert {:error, _} = chain_moves(state, [{{?h, 1}, {?g, 1}}])
    assert {:stale_mate} = WinCondition.get_winner(state)
  end
end
