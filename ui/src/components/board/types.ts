import { z } from "zod";
import * as s from "./schemas";

export type Player = z.infer<typeof s.PlayerSchema>;

export type File = z.infer<typeof s.FileSchema>;
export type Rank = z.infer<typeof s.RankSchema>;
export type Cell = z.infer<typeof s.CellSchema>;
export type Piece = z.infer<typeof s.PieceSchema>;
export type Board = z.infer<typeof s.BoardSchema>;

export type GameProps = z.infer<typeof s.GamePropsSchema>;
export type GameState = z.infer<typeof s.GameStateSchema>;
export type GameType = z.infer<typeof s.GameSchema>;
