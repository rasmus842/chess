import { useContext } from "react";
import { SocketClientContext } from "./SocketClientContext";

export function useSocketClient() {
  const client = useContext(SocketClientContext);
  if (!client) {
    throw new Error("useSocketClient must be used within SocketClientProvider");
  }
  return client;
}
