defmodule AskOuijaWeb.Presence do
  use Phoenix.Presence,
    otp_app: :ask_ouija,
    pubsub_server: AskOuija.PubSub
end
