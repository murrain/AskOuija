import Config

config :ask_ouija,
  ecto_repos: []

config :ask_ouija, AskOuijaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [formats: [html: AskOuijaWeb.ErrorHTML, json: AskOuijaWeb.ErrorJSON], layout: false],
  pubsub_server: AskOuija.PubSub,
  live_view: [signing_salt: "devsalt"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
