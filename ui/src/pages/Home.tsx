import { Link } from "react-router-dom";
import ChessBoard from "../components/ChessBoard";

export default function Home() {
  return (
    <section className="p-6 bg-gray-300 flex flex-row flex-wrap gap-6">
      <div className="p-6">
        <h1 className="text-center text-3xl font-bold my-4">Chess app</h1>
        <p className="my-4">Functionality TODO</p>
        <ul className="list-disc pl-5 space-y-2">
          <li>The chess board</li>
          <li>Sign-in and Login functionality</li>
          <li>Chat</li>
          <li>two players and others are viewers - all can access chat</li>
          <li>
            <Link to="/game/new">Create New Game</Link>
          </li>
        </ul>
      </div>
      <div className="relative">
        <ChessBoard />
      </div>
    </section>
  );
}
