defmodule AskOuijaWeb.Router do
  use AskOuijaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug AskOuijaWeb.Plugs.AssignPlayer
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", AskOuijaWeb do
    pipe_through :browser

    live "/", HomeLive, :index
    live "/rooms/:room_id", RoomLive, :show
  end
end
