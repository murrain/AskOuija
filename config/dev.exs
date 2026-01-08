import Config

config :ask_ouija, AskOuijaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "devsecret",
  watchers: []

config :phoenix, :stacktrace_depth, 20
