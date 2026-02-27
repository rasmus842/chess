import { useParams } from "react-router-dom";
import ChessBoard from "../components/board/ChessBoard";
import { useChannel } from "../hooks/useChannel";
import type { BoardMap, GameState } from "@/components/board/types";
import { useEffect, useState } from "react";

type SerializedServerState = {
  game_id: string;
  white: string;
  black: string;
  game_state: GameState;
};

export default function GamePage() {
  const { gameId } = useParams();
  const topic = `game:${gameId ?? "missing"}`;
  const { channel, isLoading, error } = useChannel(topic);
  const [board, setBoard] = useState<BoardMap | null>(null);

  useEffect(() => {
    if (!channel) {
      return;
    }
    channel
      .push("get_state", {})
      .receive("ok", (state: GameState) => {
        console.log("Got state: ", state);
        console.log("Setting board: ", state.board);
        setBoard(state.board!);
      })
      .receive("error", (e) => {
        console.log("Got error:", e);
      })
      .receive("timeout", (e) => {
        console.log("Got timeout:", e);
      });
  }, [channel]);

  return (
    <section className="p-6">
      <h1 className="text-3xl font-bold">Game</h1>
      {gameId ? <p className="mt-2 text-sm">Game ID: {gameId}</p> : null}
      {isLoading ? <p className="mt-4 text-sm">Loading game state...</p> : null}
      {error ? <p className="mt-4 text-sm text-red-600">{error}</p> : null}
      {board ? <ChessBoard board={board} /> : null}
    </section>
  );
}
