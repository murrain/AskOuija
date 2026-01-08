defmodule AskOuijaWeb do
  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: AskOuijaWeb.Layouts]

      import Plug.Conn
      alias AskOuijaWeb.Router.Helpers, as: Routes
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {AskOuijaWeb.Layouts, :app}

      alias AskOuijaWeb.Router.Helpers, as: Routes
      import Phoenix.Component
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      import Phoenix.Component
    end
  end

  def component do
    quote do
      use Phoenix.Component

      alias AskOuijaWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
