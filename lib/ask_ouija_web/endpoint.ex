defmodule AskOuijaWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :ask_ouija

  @session_options [
    store: :cookie,
    key: "_ask_ouija_key",
    signing_salt: "signsalt"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  plug Plug.Static,
    at: "/",
    from: :ask_ouija,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Session, @session_options
  plug AskOuijaWeb.Router
end
