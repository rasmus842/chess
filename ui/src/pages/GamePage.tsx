import { useParams } from "react-router-dom";
import ChessBoard from "../components/board/ChessBoard";
import { useChannel } from "../hooks/useChannel";
import { type Board } from "@/components/board/types";
import { useEffect, useState } from "react";
import { GameSchema } from "@/components/board/schemas";

export default function GamePage() {
  const { gameId } = useParams();
  const topic = `game:${gameId ?? "missing"}`;
  const { push, onEvent } = useChannel(topic);
  const [board, setBoard] = useState<Board | null>(null);
  const [isLoading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<any>(null);

  useEffect(() => {
    async function get_state() {
      setLoading(true);
      setError(null);
      const response = await push("get_state");
      console.log("got response", response);
      if (!response.isOk) {
        setError(response.reply);
        setLoading(false);
      } else {
        const state = GameSchema.parse(response.reply);
        setBoard(state.game_state.board);
        setLoading(false);
      }
    }
    get_state();
  }, [push, onEvent]);

  return (
    <section className="p-6 relative">
      <h1 className="text-3xl font-bold">Game</h1>
      {gameId ? <p className="mt-2 text-sm">Game ID: {gameId}</p> : null}
      {isLoading ? <p className="mt-4 text-sm">Loading game state...</p> : null}
      {error ? <p className="mt-4 text-sm text-red-600">{error}</p> : null}
      {board ? <ChessBoard board={board} /> : null}
    </section>
  );
}
