defmodule SmoothAuth.Plugs.FetchSubject do
  @moduledoc false

  import Plug.Conn

  @session_cookie "__Host-Http-sessionId"

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_cookies(conn)

    with cookies <- get_cookies(conn),
         {:ok, session_id} <- Map.fetch(cookies, @session_cookie),
         {:ok, subject} <- SmoothAuth.authenticate(session_id) do
      assign(conn, :current_subject, subject)
    else
      _ ->
        conn
        |> assign(:current_subject, nil)
        |> delete_resp_cookie(@session_cookie, path: "/", secure: true, http_only: true)
    end
  end
end
