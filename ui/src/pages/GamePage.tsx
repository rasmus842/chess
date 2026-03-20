import { useParams } from "react-router-dom";
import ChessBoard from "../components/board/ChessBoard";
import { useChannel, useChannelEvent } from "../hooks/useChannel";
import { type GameState } from "@/components/board/types";
import { useEffect, useState } from "react";
import { GameSchema } from "@/components/board/schemas";

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
      const response = await push("get_state");
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

  return (
    <section className="p-6 relative">
      <h1 className="text-3xl font-bold">Game</h1>
      {gameId ? <p className="mt-2 text-sm">Game ID: {gameId}</p> : null}
      {isLoading ? <p className="mt-4 text-sm">Loading game state...</p> : null}
      {error ? <p className="mt-4 text-sm text-red-600">{error}</p> : null}
      {gameState ? <ChessBoard board={gameState.board} /> : null}
    </section>
  );
}
