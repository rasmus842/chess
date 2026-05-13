defmodule ChessWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :chess
  
  # TODO:
  # Always HTTPS, HSTS (Set-Secure-Transport header)
  # CSRF (custom X-CSRF-TOKEN header)

  # TODO:
  # websocket security (security token + csrf token)
  # Dynamically authenticatable websocket connections?
  # Incoming and outgoing events:
  # both: Verify subject exists? If not then reject?
  # Reject with redirect or error?
  socket "/socket", ChessWeb.UserSocket,
    websocket: true,
    longpoll: false

  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :chess
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.Head
  plug SmoothAuth.Plugs.FetchSubject
  plug ChessWeb.Router
end
