defmodule AskOuijaWeb.ChatComponent do
  use AskOuijaWeb, :live_component

  alias AskOuija.RoomServer

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns) |> assign_new(:body, fn -> "" end)}
  end

  @impl true
  def handle_event("chat:send", %{"body" => body}, socket) do
    _ = RoomServer.post_chat_message(socket.assigns.room_id, socket.assigns.player_id, body)
    {:noreply, assign(socket, :body, "")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="card stack">
      <h3>Room Chat</h3>
      <div class="chat">
        <%= for message <- @messages do %>
          <div>
            <strong><%= message.player_name %>:</strong>
            <span><%= message.body %></span>
            <span class="muted">(<%= format_time(message.inserted_at) %>)</span>
          </div>
        <% end %>
      </div>
      <form phx-submit="chat:send" phx-target={@myself} id="chat-form">
        <div class="row">
          <input type="text" name="body" value={@body} maxlength="240" placeholder="Say something" autocomplete="off" />
          <button type="submit">Send</button>
        </div>
      </form>
    </div>
    """
  end

  defp format_time(ms) do
    ms
    |> DateTime.from_unix!(:millisecond)
    |> Calendar.strftime("%H:%M:%S")
  end
end
