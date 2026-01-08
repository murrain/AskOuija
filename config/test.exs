import Config

config :ask_ouija, AskOuijaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "testsecret",
  server: false

config :logger, level: :warning
