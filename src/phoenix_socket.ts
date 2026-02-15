import { Socket, Channel } from "phoenix";

/**
 * TODO: move phoenix socket client and useChannel into a separate project
 * Also. wrap the socket client/useChannel in some interface
 */
class BackendSocketClient {
  private socket: Socket | null = null;
  private channels = new Map<string, Channel>();
  private joinings = new Map<string, Promise<Channel>>();
  private refCount = new Map<string, number>();
  private pendingLeave = new Map<string, number>();

  connect(token?: string) {
    if (this.socket) {
      return;
    }
    console.info(`CONNECTING socket`);
    this.socket = new Socket("/socket", {
      params: token ? { token } : {},
      //logger: (kind, msg, data) => {
      // console.log(`[PHX ${kind}] ${msg}`, data);
      //},
    });
    this.socket.connect();
  }

  disconnect() {
    console.info(`DISCONNECTING socket`);
    for (const channel of this.channels.values()) {
      channel.leave();
    }
    this.channels.clear();
    this.joinings.clear();
    this.refCount.clear();
    this.pendingLeave.clear();
    this.socket?.disconnect();
    this.socket = null;
  }

  async join(topic: string, channelParams?: object): Promise<Channel> {
    if (!this.socket) {
      throw new Error("Socket not connected. Call connect() first.");
    }
    this.refCount.set(topic, (this.refCount.get(topic) ?? 0) + 1);
    const existing = this.channels.get(topic);
    if (existing) {
      return existing;
    }
    const inFlight = this.joinings.get(topic);
    if (inFlight) {
      return inFlight;
    }
    const channel = this.socket.channel(topic, channelParams ?? {});
    const joining = new Promise<Channel>((resolve, reject) => {
      channel
        .join()
        .receive("ok", (resp) => {
          console.info(`JOINED CHANNEL ${topic}, params:`, resp);
          this.channels.set(topic, channel);
          this.joinings.delete(topic);
          resolve(channel);
        })
        .receive("error", (err) => {
          console.error(`ERROR joining channel ${topic}`, err);
          this.joinings.delete(topic);
          reject(err);
        })
        .receive("timeout", (err) => {
          console.error(`TIMEOUT joining channel ${topic}`, err);
          this.joinings.delete(topic);
          reject(err);
        });
    });
    this.joinings.set(topic, joining);
    return joining;
  }

  async release(topic: string) {
    const next = (this.refCount.get(topic) ?? 0) - 1;
    if (next > 0) {
      this.refCount.set(topic, next);
      return;
    }
    this.refCount.delete(topic);

    const pendingLeave = this.pendingLeave.get(topic);
    if (pendingLeave) {
      // if joined - released, then clear existing leave
      window.clearTimeout(pendingLeave);
    }
    const scheduledLeave = window.setTimeout(async () => {
      this.pendingLeave.delete(topic);
      const c = this.refCount.get(topic) ?? 0;
      if (c > 0) {
        // if rejoined, cancel leave
        return;
      }
      console.info(`LEAVE channel ${topic}`);

      let channel = null;
      const existing = this.channels.get(topic);
      if (existing) {
        channel = existing;
      } else {
        const joining = this.joinings.get(topic);
        if (joining) {
          channel = await joining.catch(() => null);
        }
      }
      channel?.leave();
      this.channels.delete(topic);
      this.joinings.delete(topic);
    }, 1000);
    this.pendingLeave.set(topic, scheduledLeave);
  }
}

const socketClient = new BackendSocketClient();

export default socketClient;
