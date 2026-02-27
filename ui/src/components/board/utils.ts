import * as t from "./types";

export function isLightSquare(rank: t.Rank, fileIndex: number) {
  return (rank + fileIndex) % 2 === 1;
}

const pieceForInitialPosition = (file: t.File, rank: t.Rank): t.Piece | null => {
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

export const initial_board: t.BoardMap = (() => {
  const boardMap: t.BoardMap = {};
  for (const file of t.files) {
    for (const rank of t.ranks) {
      const piece = pieceForInitialPosition(file, rank);
      if (piece) {
        const cell = `${file}${rank}` as t.Cell;
        boardMap[cell] = piece;
      }
    }
  }
  return boardMap;
})();
