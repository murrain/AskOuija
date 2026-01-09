defmodule AskOuijaWeb.Layouts do
  use AskOuijaWeb, :component

  def app(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <title>AskOuija</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta name="csrf-token" content={Phoenix.Controller.get_csrf_token()} />
        <style>
          body { font-family: system-ui, sans-serif; margin: 0; background: #111827; color: #f9fafb; }
          .container { max-width: 1100px; margin: 0 auto; padding: 2rem; }
          .card { background: #1f2937; border-radius: 12px; padding: 1.5rem; margin-bottom: 1rem; }
          .stack { display: grid; gap: 1rem; }
          .row { display: flex; gap: 1rem; align-items: center; }
          input, select, button { padding: 0.6rem 0.8rem; border-radius: 8px; border: 1px solid #374151; background: #111827; color: #f9fafb; }
          button { background: #6366f1; border: none; cursor: pointer; }
          button.secondary { background: #374151; }
          .pill { padding: 0.2rem 0.6rem; border-radius: 999px; background: #374151; font-size: 0.8rem; }
          .grid { display: grid; grid-template-columns: 2fr 1fr; gap: 1rem; }
          .chat { max-height: 320px; overflow-y: auto; display: flex; flex-direction: column-reverse; gap: 0.5rem; }
          .muted { color: #9ca3af; }
          .answers { margin-top: 1rem; }
        </style>
        <script src="https://cdn.jsdelivr.net/npm/phoenix@1.7.12/priv/static/phoenix.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/phoenix_live_view@0.20.0/priv/static/phoenix_live_view.min.js"></script>
        <script>
          const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
          const liveSocket = new window.LiveSocket("/live", window.Phoenix.Socket, {
            params: { _csrf_token: csrfToken }
          });

          liveSocket.connect();
          window.liveSocket = liveSocket;
        </script>
      </head>
      <body>
        <div class="container">
          <%= @inner_content %>
        </div>
      </body>
    </html>
    """
  end
end
