import { Socket, Channel } from "phoenix";

class BackendSocketClient {
  private socket: Socket | null = null;
  private channels = new Map<string, Channel>();
  private joinings = new Map<string, Promise<Channel>>();

  connect(token?: string) {
    if (this.socket) {
      return;
    }
    this.socket = new Socket("/socket", {
      params: token ? { token } : {},
    });
    this.socket.connect();
  }

  disconnect() {
    for (const channel of this.channels.values()) {
      channel.leave();
    }
    this.channels.clear();
    this.socket?.disconnect();
    this.joinings.clear();
    this.socket = null;
  }

  async join(topic: string, channelParams?: object): Promise<Channel> {
    if (!this.socket) {
      throw new Error("Socket not connected. Call connect() first.");
    }
    const existing = this.channels.get(topic);
    if (existing) {
      return existing;
    }
    const inFlight = this.joinings.get(topic);
    if (inFlight) {
      return inFlight;
    }
    const params = channelParams ? channelParams : {};
    const channel = this.socket.channel(topic, params);
    const joining = new Promise<Channel>((resolve, reject) => {
      channel
        .join()
        .receive("ok", (_resp) => {
          this.channels.set(topic, channel);
          this.joinings.delete(topic);
          resolve(channel);
        })
        .receive("error", (err) => {
          this.joinings.delete(topic);
          reject(err);
        });
    });
    this.joinings.set(topic, joining);
    return joining;
  }

  async leave(topic: string) {
    let channel = null;
    const joining = this.joinings.get(topic);
    if (joining) {
      channel = await joining;
    } else {
      channel = this.channels.get(topic);
    }
    channel?.leave();
    this.channels.delete(topic);
  }
}

const socketClient = new BackendSocketClient();

export default socketClient;
