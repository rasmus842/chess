import socketClient from "@/phoenix_socket";
import { Channel } from "phoenix";
import { useEffect, useRef, useState } from "react";

export const useChannel = (topic: string, channelParams?: object) => {
  const [channel, setChannel] = useState<Channel | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let mounted = true;

    async function join() {
      try {
        const ch = await socketClient.join(topic, channelParams);
        if (mounted) {
          setChannel(ch);
        }
      } catch (e) {
        if (mounted) {
          setChannel(null);
          setError(`Failed to subscribe to topic ${topic}`);
        }
      }
    }
    join();

    return () => {
      mounted = false;
    };
  }, [topic, channelParams]);

  return { channel: channel, error: error };
};
