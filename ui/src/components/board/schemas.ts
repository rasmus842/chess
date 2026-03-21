import { z } from "zod";

export const PlayerSchema = z.enum(["white", "black"]);

export const PieceSchema = z.enum([
  "white_pawn",
  "white_rook",
  "white_knight",
  "white_bishop",
  "white_queen",
  "white_king",
  "black_pawn",
  "black_rook",
  "black_knight",
  "black_bishop",
  "black_queen",
  "black_king",
]);

export const files = ["a", "b", "c", "d", "e", "f", "g", "h"] as const;
export const ranks = [8, 7, 6, 5, 4, 3, 2, 1] as const;
export const FileSchema = z.literal(files);
export const RankSchema = z.literal(ranks);
export const CellSchema = z.templateLiteral([FileSchema, RankSchema]);

export const BoardSchema = z.partialRecord(CellSchema, PieceSchema);

export const GamePropsSchema = z.object({
  player: PlayerSchema,
  active_en_passant: z.object({ pawn: CellSchema, target: CellSchema }).nullable(),
  white_king: CellSchema.nullable(),
  black_king: CellSchema.nullable(),
  white_king_moved: z.boolean(),
  black_king_moved: z.boolean(),
  a1_rook_moved: z.boolean(),
  a8_rook_moved: z.boolean(),
  h1_rook_moved: z.boolean(),
  h8_rook_moved: z.boolean(),
});

export const GameStateSchema = z.object({
  board: BoardSchema,
  props: GamePropsSchema,
  possible_moves: z.partialRecord(CellSchema, z.array(CellSchema)),
  checks: z.partialRecord(CellSchema, z.array(CellSchema)),
});

export const GameSchema = z.object({
  game_id: z.string(),
  game_state: GameStateSchema,
  white: z.string(),
  black: z.string(),
});
