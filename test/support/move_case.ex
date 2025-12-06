defmodule Chess.Game.MoveCase do
  use ExUnit.CaseTemplate, async: true

  using do
    quote do
      use Chess.Game.Types
      alias Chess.Game.Move
      alias Chess.Game.Props

      @doc """
      Helper method for tests. Assume that the player making the
      move is always correct
      Also assume that the origin of the move has an existing piece.
      """
      @spec test_make_move(board(), move()) :: {:ok, game_state() | error()}
      def test_make_move(board, {origin, _destination} = move) when is_map(board) do
        {color, _kind} = _piece = Map.get(board, origin)
        game_state = {%Props{player: color}, board}
        action = {game_state, move, color}
        Move.make_move(action)
      end

      @spec assert_move_is_ok(board(), move()) :: game_state()
      def assert_move_is_ok(board, move) do
        assert {:ok, new_state} = test_make_move(board, move)
        new_state
      end

      @spec assert_move_is_error(board(), move()) :: String.t()
      def assert_move_is_error(board, move) do
        assert {:error, message} = test_make_move(board, move)
        message
      end

      @spec chain_moves(game_state(), [move()]) :: game_state() | error()
      def chain_moves(state, []), do: {:ok, state}

      def chain_moves(state = {%Props{player: player}, board}, [move | rest]) do
        action = {state, move, player}

        case Move.make_move(action) do
          {:error, message} = err -> err
          {:ok, new_state} -> chain_moves(new_state, rest)
        end
      end
    end
  end
end
