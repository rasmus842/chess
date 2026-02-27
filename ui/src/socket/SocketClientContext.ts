import type { SocketClient } from "./SocketClient";
import { createContext } from "react";

export const SocketClientContext = createContext<SocketClient | null>(null);
