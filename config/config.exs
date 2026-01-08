import Config

config :ask_ouija,
  ecto_repos: []

config :ask_ouija, AskOuija.Prompts,
  provider: AskOuija.Prompts.LocalProvider,
  file_path: "priv/data/reddit_prompts.json"

config :ask_ouija, AskOuija.Scraper,
  enabled: false,
  schedule_interval_ms: 86_400_000,
  subreddit: "AskOuija",
  limit: 100,
  user_agent: "ask_ouija_scraper/0.1",
  output_path: "priv/data/reddit_prompts.json"

config :ask_ouija, AskOuijaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: AskOuijaWeb.ErrorHTML, json: AskOuijaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: AskOuija.PubSub,
  live_view: [signing_salt: "devsalt"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
