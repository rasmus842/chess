import { useParams } from "react-router-dom";
import ChessBoard from "../components/ChessBoard";
import { useChannel } from "../hooks/useChannel";

type PieceName =
  | "white_pawn"
  | "white_rook"
  | "white_knight"
  | "white_bishop"
  | "white_queen"
  | "white_king"
  | "black_pawn"
  | "black_rook"
  | "black_knight"
  | "black_bishop"
  | "black_queen"
  | "black_king";

type BoardMap = Record<string, PieceName>;

type SerializedProps = {
  player: "white" | "black";
  active_en_passant: [string, string] | null;
  white_king: string | null;
  black_king: string | null;
  white_king_moved: boolean;
  black_king_moved: boolean;
  a1_rook_moved: boolean;
  a8_rook_moved: boolean;
  h1_rook_moved: boolean;
  h8_rook_moved: boolean;
};

type SerializedGameState = {
  board: BoardMap;
  props: SerializedProps;
  possible_moves: Record<string, string[]>;
  checks: Record<string, string[]>;
};

type SerializedServerState = {
  game_id: string;
  white: string;
  black: string;
  game_state: SerializedGameState;
};

type JoinResponse = {
  state: SerializedServerState;
};

export default function GamePage() {
  const { gameId } = useParams();
  const topic = `game:${gameId ?? "missing"}`;
  const [_channel, state, _setState, error] = useChannel<JoinResponse>(topic);
  const board = state?.state?.game_state?.board ?? {};
  const isLoading = !state && !error;

  return (
    <section className="p-6">
      <h1 className="text-3xl font-bold">Game</h1>
      {gameId ? <p className="mt-2 text-sm">Game ID: {gameId}</p> : null}
      {isLoading ? <p className="mt-4 text-sm">Loading game state...</p> : null}
      {error ? <p className="mt-4 text-sm text-red-600">{error}</p> : null}
      {!error && !isLoading ? <ChessBoard board={board} /> : null}
    </section>
  );
}
