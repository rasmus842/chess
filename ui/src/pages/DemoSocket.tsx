import { useChannel } from "@/hooks/phoenix_channel";
import { useCallback, useEffect } from "react";

export default function DemoSocket() {
  const { channel, error } = useChannel("game");

  useEffect(() => {
    if (!channel) {
      return;
    }
    console.log("channel state: ", channel.state);

    channel.on("move_made", (p) => console.log("move_made", p));

    return () => {
      channel.off("move_made");
    };
  }, [channel]);

  const makeMove = useCallback(() => {
    console.log("Making move");
    channel
      ?.push("move", { from: "a2", to: "a3" }, 2000)
      .receive("ok", (msg) => console.log("got OK after move", msg))
      .receive("error", (reasons) => console.log("got ERROR after move", reasons))
      .receive("timeout", () => console.log("got TIMEOUT after move"));
  }, [channel]);

  return (
    <section className="p-10">
      {channel && (
        <>
          <p>Successfully connected to channel</p>
          <button onClick={makeMove}>Make move</button>
        </>
      )}
      {error && <p>Got error connecting to channel: {error}</p>}
    </section>
  );
}
