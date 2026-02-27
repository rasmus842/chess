import { useMemo } from "react";
import { SocketClient } from "./SocketClient";
import { SocketClientContext } from "./SocketClientContext";

type Props = {
  children: React.ReactNode;
  token?: string;
};

export function SocketClientProvider({ children, token }: Props) {
  const client = useMemo(() => {
    const c = new SocketClient();
    c.connect(token);
    return c;
  }, [token]);

  return <SocketClientContext.Provider value={client}>{children}</SocketClientContext.Provider>;
}
