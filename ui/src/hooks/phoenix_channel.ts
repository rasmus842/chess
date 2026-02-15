import socketClient from "@/phoenix_socket";
import { Channel } from "phoenix";
import { useEffect, useState } from "react";

export const useChannel = (topic: string, joinParams?: object) => {
  const [channel, setChannel] = useState<Channel | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function join() {
      try {
        const ch = await socketClient.join(topic, joinParams);
        if (cancelled) {
          return;
        }
        setChannel(ch);
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

  return { channel: channel, error: error };
};
