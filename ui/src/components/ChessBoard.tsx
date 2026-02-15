const files = ["a", "b", "c", "d", "e", "f", "g", "h"] as const;
const ranks = [8, 7, 6, 5, 4, 3, 2, 1] as const;

type File = (typeof files)[number];
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

const pieceForInitialPosition = (file: File, rank: number): Piece | null => {
  if (rank === 2) return "white_pawn";
  if (rank === 7) return "black_pawn";
  if (rank === 1 && (file === "a" || file === "h")) return "white_rook";
  if (rank === 8 && (file === "a" || file === "h")) return "black_rook";
  if (rank === 1 && (file === "b" || file === "g")) return "white_knight";
  if (rank === 8 && (file === "b" || file === "g")) return "black_knight";
  if (rank === 1 && (file === "c" || file === "f")) return "white_bishop";
  if (rank === 8 && (file === "c" || file === "f")) return "black_bishop";
  if (rank === 1 && file === "d") return "white_queen";
  if (rank === 8 && file === "d") return "black_queen";
  if (rank === 1 && file === "e") return "white_king";
  if (rank === 8 && file === "e") return "black_king";
  return null;
};

const isLightSquare = (rank: number, fileIndex: number) => (rank + fileIndex) % 2 === 1;

export default function ChessBoard() {
  return (
    <div className="m-8 grid grid-cols-8 grid-rows-8 overflow-auto border border-solid border-[#7c5c3b]">
      {ranks.flatMap((rank) =>
        files.map((file, index) => {
          const piece = pieceForInitialPosition(file, rank);
          const isLight = isLightSquare(rank, index + 1);

          return (
            <div
              key={`${file}${rank}`}
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
