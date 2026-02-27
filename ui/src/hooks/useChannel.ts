import socketClient from "@/phoenix_socket";
import { Channel } from "phoenix";
import { useEffect, useState } from "react";

export function useChannel<T>(topic: string, joinParams?: object) {
  const [channel, setChannel] = useState<Channel | null>(null);
  const [state, setState] = useState<T | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function join() {
      try {
        const [ch, st] = await socketClient.join(topic, joinParams);
        if (cancelled) {
          return;
        }
        setChannel(ch);
        setState(st);
      } catch (e) {
        if (!cancelled) {
          setChannel(null);
          setError(`Failed to subscribe to topic ${topic}`);
        }
      }
    }
    join();

    return () => {
      cancelled = true;
      socketClient.release(topic);
    };
  }, [topic, joinParams]);

  return [channel, state, setState, error];
}
