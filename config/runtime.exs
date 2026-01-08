import Config

if config_env() == :prod do
  config :ask_ouija, AskOuijaWeb.Endpoint,
    http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT") || "4000")],
    secret_key_base: System.get_env("SECRET_KEY_BASE") || "prodsecret"
end
