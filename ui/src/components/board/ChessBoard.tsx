import { files, ranks } from "./schemas";
import { type Board, type Cell } from "./types";
import { initial_board, isLightSquare } from "./utils";

type ChessBoardProps = {
  board?: Board;
};

export default function ChessBoard({ board = initial_board }: ChessBoardProps) {
  return (
    <div className="m-8 inline-grid grid-cols-8 grid-rows-8 border border-solid border-[#7c5c3b]">
      {ranks.flatMap((rank) =>
        files.map((file, index) => {
          const key = `${file}${rank}` as Cell;
          const piece = board[key];
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
              {piece ? (
                <img
                  src={`/images/${piece}.svg`}
                  alt={`Chess piece ${piece}`}
                  className="max-h-full max-w-full"
                />
              ) : null}
            </div>
          );
        }),
      )}
    </div>
  );
}
