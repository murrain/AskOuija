defmodule AskOuijaWeb.HomeLive do
  use AskOuijaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       room_code: "",
       errors: []
     )}
  end

  @impl true
  def handle_event("create", _params, socket) do
    room_id = random_room_code()
    {:noreply, push_navigate(socket, to: Routes.live_path(socket, AskOuijaWeb.RoomLive, room_id))}
  end

  def handle_event("join", %{"room" => room}, socket) do
    room_id = room |> String.trim() |> String.downcase()

    if room_id == "" do
      {:noreply, assign(socket, errors: ["Enter a room code to join."])}
    else
      {:noreply, push_navigate(socket, to: Routes.live_path(socket, AskOuijaWeb.RoomLive, room_id))}
    end
  end

  defp random_room_code do
    :crypto.strong_rand_bytes(3) |> Base.url_encode64(padding: false) |> String.downcase()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="stack">
      <div class="card">
        <h1>Speed Trivia</h1>
        <p class="muted">Real-time multiplayer trivia in rapid-fire rounds.</p>
      </div>

      <div class="card stack">
        <h2>Create a room</h2>
        <button phx-click="create">Create room</button>
      </div>

      <div class="card stack">
        <h2>Join with a code</h2>
        <form phx-submit="join">
          <div class="row">
            <input type="text" name="room" placeholder="room code" />
            <button type="submit">Join</button>
          </div>
        </form>
        <%= for error <- @errors do %>
          <p class="muted"><%= error %></p>
        <% end %>
      </div>
    </div>
    """
  end
end
