import { useParams } from "react-router-dom";
import ChessBoard from "../components/board/ChessBoard";
import { useChannel, useChannelEvent } from "../hooks/useChannel";
import { type Cell, type GameState } from "@/components/board/types";
import { useCallback, useEffect, useState } from "react";
import { GameSchema, GameStateSchema } from "@/components/board/schemas";
import PlayableChessBoard from "@/components/board/PlayableChessBoard";

export default function GamePage() {
  const { gameId } = useParams();
  const topic = `game:${gameId ?? "missing"}`;
  const { channel, push } = useChannel(topic);
  const [gameState, setGameState] = useState<GameState | null>(null);
  const [isLoading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<any>(null);

  useEffect(() => {
    if (!channel) {
      return;
    }
    async function get_state() {
      setLoading(true);
      setError(null);
      const response = await push("get_game");
      console.log("got response", response);
      if (!response.isOk) {
        setError(response.reply);
      } else {
        const game = GameSchema.parse(response.reply);
        setGameState(game.game_state);
      }
      setLoading(false);
    }
    get_state();
  }, [channel, push]);

  useChannelEvent(channel, "move_made", (payload) => {
    const updated_game = GameSchema.parse(payload);
    setGameState(updated_game.game_state);
  });

  const makeMove = useCallback(
    async (from: Cell, to: Cell) => {
      console.log(`makeMove: ${from} => ${to}`);
      if (!from || !to || !gameState?.possible_moves) {
        return;
      }
      if (!gameState.possible_moves[from]?.includes(to)) {
        console.log(`Illegal move: ${from} => ${to}`);
        return;
      }
      // TODO: player should be the uuid given by the server
      const piece = gameState.board[from];
      const color = piece!.startsWith("white") ? "white" : "black";
      const response = await push("move", { from: from, to: to, player: color });
      if (!response.isOk) {
        console.error("Failed to make move!", response.reply);
        return;
      }
      console.log(response.reply);
      const updated_state = GameStateSchema.parse(response.reply);
      setGameState(updated_state);
    },
    [gameState, push],
  );

  return (
    <section className="p-6 relative">
      <h1 className="text-3xl font-bold">Game</h1>
      {gameId ? <p className="mt-2 text-sm">Game ID: {gameId}</p> : null}
      {isLoading ? <p className="mt-4 text-sm">Loading game state...</p> : null}
      {error ? <p className="mt-4 text-sm text-red-600">{error}</p> : null}
      {gameState ? <PlayableChessBoard state={gameState} onMove={makeMove} /> : null}
    </section>
  );
}
