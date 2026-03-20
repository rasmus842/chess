import { useSocketClient } from "@/socket/useSocketClient";
import { Channel } from "phoenix";
import { useCallback, useEffect, useMemo, useState } from "react";

const DEFAULT_TIMEOUT_MS = 5_000;

export type PushResult = {
  isOk: boolean;
  reply: unknown;
};

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

  const push = useCallback(
    (event: string, payload?: object): Promise<PushResult> => {
      if (!channel) {
        return Promise.resolve({ isOk: false, reply: "Channel not open" });
      }
      return new Promise((resolve) => {
        channel
          .push(event, payload ?? {}, DEFAULT_TIMEOUT_MS)
          .receive("ok", (reply) => resolve({ isOk: true, reply }))
          .receive("error", (reply) => resolve({ isOk: false, reply }))
          .receive("timeout", () => {
            console.error(`Failed to push event ${event} to ${topic}, got timeout`);
            resolve({ isOk: false, reply: "Timeout" });
          });
      });
    },
    [channel, topic],
  );

  const onEvent = useCallback(
    (event: string, handler: (payload: unknown) => void) => {
      if (!channel) {
        // no-op unsubscribe
        return () => {};
      }
      channel.on(event, handler);
      return () => {
        // return an unsubscibe function
        channel.off(event);
      };
    },
    [channel],
  );
  return { channel, isLoading, error, push, onEvent };
}
