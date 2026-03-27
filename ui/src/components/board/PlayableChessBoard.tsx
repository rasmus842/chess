import {
  DndContext,
  useDraggable,
  useDroppable,
  type DragEndEvent,
} from "@dnd-kit/core";
import { files, ranks } from "./schemas";
import { type Cell, type GameState, type Piece } from "./types";
import { isLightSquare } from "./utils";
import { CSS } from "@dnd-kit/utilities";

type SquareProps = {
  id: Cell;
  isLight: boolean;
  children?: React.ReactNode;
};

function Square({ id, isLight, children }: SquareProps) {
  const { setNodeRef, isOver } = useDroppable({ id });

  return (
    <div
      ref={setNodeRef}
      className={[
        "sm:size-8 md:size-16 flex items-center justify-center",
        isLight ? "bg-green-50" : "bg-green-700",
        isOver ? "outline outline-2 outline-yello-400" : "",
      ].join(" ")}
      data-cell={id}
    >
      {children}
    </div>
  );
}

type DraggablePieceProps = {
  cell: Cell;
  piece: Piece;
};

function MovablePiece({ cell, piece }: DraggablePieceProps) {
  const { attributes, listeners, setNodeRef, transform, isDragging } = useDraggable({
    id: cell,
    data: { piece },
  });

  const style: React.CSSProperties = {
    transform: CSS.Translate.toString(transform),
    opacity: isDragging ? 0.6 : 1,
    touchAction: "none",
  };

  return (
    <img
      ref={setNodeRef}
      style={style}
      {...listeners}
      {...attributes}
      src={`/images/${piece}.svg`}
      alt={piece}
      className="max-h-full max-w-full cursor-grab active:cursor-grabbing select-none"
      draggable={false} // prevent native HTML5 dragging
    />
  );
}

type ImmovablePieceProps = {
  piece: Piece;
};

function ImmovablePiece({ piece }: ImmovablePieceProps) {
  return (
    <img
      src={`/images/${piece}.svg`}
      alt={piece}
      className="max-h-full max-w-full cursor-grab active:cursor-grabbing select-none"
    />
  );
}

type ChessBoardProps = {
  state: GameState;
  onMove?: (from: Cell, to: Cell) => void;
};

export default function PlayableChessBoard({ state, onMove }: ChessBoardProps) {
  const { board, possible_moves } = state;

  const handleDragEnd = (event: DragEndEvent) => {
    console.log("handleDragEnd");
    if (!onMove) {
      return;
    }
    const from = event.active.id as Cell;
    const to = event.over?.id as Cell;

    if (!to || from === to) {
      return;
    }
    onMove(from, to);
  };

  return (
    <DndContext onDragEnd={handleDragEnd}>
      <div className="m-8 inline-grid grid-cols-8 grid-rows-8 border border-solid border-[#7c5c3b]">
        {ranks.flatMap((rank) =>
          files.map((file, index) => {
            const cell = `${file}${rank}` as Cell;
            const piece = board[cell];
            const isLight = isLightSquare(rank, index + 1);
            const isMoveable = !!possible_moves[cell]?.length;
            return (
              <Square key={cell} id={cell} isLight={isLight}>
                {piece && isMoveable && <MovablePiece cell={cell} piece={piece} />}
                {piece && !isMoveable && <ImmovablePiece piece={piece} />}
              </Square>
            );
          }),
        )}
      </div>
    </DndContext>
  );
}
