export type Player = "white" | "black";

export const files = ["a", "b", "c", "d", "e", "f", "g", "h"] as const;
export const ranks = [8, 7, 6, 5, 4, 3, 2, 1] as const;

export type File = (typeof files)[number];
export type Rank = (typeof ranks)[number];
export type Cell = `${File}${Rank}`;

export type Piece =
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

export type BoardMap = Partial<Record<Cell, Piece>>;

export type GameProps = {
  player: "white" | "black";
  active_en_passant: [string, string] | null;
  white_king: Cell | null;
  black_king: Cell | null;
  white_king_moved: boolean;
  black_king_moved: boolean;
  a1_rook_moved: boolean;
  a8_rook_moved: boolean;
  h1_rook_moved: boolean;
  h8_rook_moved: boolean;
};

export type GameState = {
  board: BoardMap;
  props: GameProps;
  possible_moves: Partial<Record<Cell, Cell[]>>;
  checks: Partial<Record<Cell, Cell[]>>;
};
