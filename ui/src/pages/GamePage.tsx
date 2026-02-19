import { useParams } from "react-router-dom";

export default function GamePage() {
  const { gameId } = useParams();

  return (
    <section className="p-6">
      <h1 className="text-3xl font-bold">Game</h1>
      {gameId ? <p className="mt-2 text-sm">Game ID: {gameId}</p> : null}
    </section>
  );
}
