defmodule AskOuija.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: AskOuija.RoomRegistry},
      {Phoenix.PubSub, name: AskOuija.PubSub},
      AskOuijaWeb.Presence,
      AskOuija.RoomSupervisor,
      AskOuijaWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: AskOuija.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    AskOuijaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
