import { useEffect, useState } from "react";

const files = ["a", "b", "c", "d", "e", "f", "g", "h"] as const;
const ranks = [8, 7, 6, 5, 4, 3, 2, 1] as const;

type Piece =
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

type BoardMap = Record<string, Piece>;

const isLightSquare = (rank: number, fileIndex: number) => (rank + fileIndex) % 2 === 1;

type ChessBoardProps = {
  board: BoardMap;
};

export default function ChessBoard({ board }: ChessBoardProps) {
  const [boardState, setBoardState] = useState<BoardMap>(board);

  useEffect(() => {
    setBoardState(board);
  }, [board]);

  return (
    <div className="m-8 grid grid-cols-8 grid-rows-8 overflow-auto border border-solid border-[#7c5c3b]">
      {ranks.flatMap((rank) =>
        files.map((file, index) => {
          const key = `${file}${rank}`;
          const piece = boardState[key];
          const isLight = isLightSquare(rank, index + 1);

          return (
            <div
              key={key}
              className={[
                "sm:size-8 md:size-16 flex items-center justify-center",
                isLight ? "bg-green-50" : "bg-green-700",
              ].join(" ")}
              data-row={rank}
              data-col={file}
            >
              {piece ? <img src={`/images/${piece}.svg`} alt="Chess piece" /> : null}
            </div>
          );
        }),
      )}
    </div>
  );
}
