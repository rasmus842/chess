defmodule Chess.Game.MoveCase do
  alias Chess.Game.GameState
  use ExUnit.CaseTemplate, async: true

  using do
    quote do
      alias Chess.Game.Types, as: T
      alias Chess.Game.Props
      alias Chess.Game.GameState
      alias Chess.Game.Action
      alias Chess.Game.Utils
      alias Chess.Game.Move

      @doc """
      Helper method for tests. Assume that the player making the
      move is always correct
      Also assume that the origin of the move has an existing piece.
      """
      @spec test_make_move(T.board(), T.move()) :: T.result(GameState.t())
      def test_make_move(board, {origin, _destination} = move) when is_map(board) do
        {color, _kind} = _piece = Map.get(board, origin)

        action = %Action{
          game_state: GameState.new(board: board, player: color),
          move: move,
          params: %{player: color}
        }

        Move.make_move(action)
      end

      @spec assert_move_is_ok(T.board(), T.move()) :: GameState.t()
      def assert_move_is_ok(board, move) do
        assert {:ok, new_state} = test_make_move(board, move)
        new_state
      end

      @spec assert_move_is_error(T.board(), T.move()) :: term()
      def assert_move_is_error(board, move) do
        assert {:error, message} = test_make_move(board, move)
        message
      end

      @spec chain_moves(GameState.t(), [T.move()]) :: T.result(GameState.t())
      def chain_moves(state, []), do: {:ok, state}

      def chain_moves(state = %GameState{board: board, props: %Props{player: player}}, [
            move | rest
          ]) do
        action = %Action{
          game_state: state,
          move: move,
          params: %{player: player}
        }

        case Move.make_move(action) do
          {:error, message} = err -> err
          {:ok, new_state} -> chain_moves(new_state, rest)
        end
      end
    end
  end
end
