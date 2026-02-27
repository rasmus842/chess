import { useSocketClient } from "@/socket/useSocketClient";
import { Channel } from "phoenix";
import { useEffect, useMemo, useState } from "react";

export function useChannel<P extends object>(topic: string, params?: P) {
  const socketClient = useSocketClient();
  const [channel, setChannel] = useState<Channel | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // React fails to check javascript objects correctly. memoize to avoid rerendering
  const paramsKey = useMemo(() => JSON.stringify(params ?? {}), [params]);

  useEffect(() => {
    let cancelled = false;

    async function join() {
      setIsLoading(true);
      setError(null);
      try {
        const ch = await socketClient.join(topic, params ?? {});
        if (!cancelled) {
          setChannel(ch);
        }
      } catch (e) {
        if (!cancelled) {
          console.error(`Failed to join Channel{topic=${topic}, params=${params}}`, e);
          setChannel(null);
          setError(e instanceof Error ? e.message : "Failed to join channel");
        }
      } finally {
        if (!cancelled) {
          setIsLoading(false);
        }
      }
    }
    join();

    return () => {
      cancelled = true;
      socketClient.release(topic);
    };
  }, [socketClient, topic, paramsKey]);

  return { channel, isLoading, error };
}
