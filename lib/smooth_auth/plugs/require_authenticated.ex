defmodule SmoothAuth.Plugs.RequireAuthenticated do
  @moduledoc false

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns[:current_subject] do
      nil ->
        conn
          |> put_resp_content_type("application/json")
          |> send_resp(401, ~s({"error": "Unauthorized", "authentication_path": "/auth/login"}))
          |> halt()

      _subject ->
        conn
    end
  end
end
