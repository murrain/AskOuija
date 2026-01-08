defmodule AskOuijaWeb.RoomLive do
  use AskOuijaWeb, :live_view

  alias AskOuija.{Accounts, RoomServer, RoomSupervisor}
  alias AskOuijaWeb.{ChatComponent, Presence}

  @impl true
  def mount(%{"room_id" => room_id}, session, socket) do
    {:ok, _pid} = RoomSupervisor.get_or_start_room(room_id)

    player = %{
      id: session["player_id"],
      name: session["player_name"],
      avatar_seed: session["avatar_seed"],
      ready: false
    }

    if connected?(socket) do
      Phoenix.PubSub.subscribe(AskOuija.PubSub, topic(room_id))
      Presence.track(self(), topic(room_id), player.id, %{name: player.name, ready: false, total_score: 0})
    end

    {:ok, engine} = RoomServer.join(room_id, player)

    {:ok,
     assign(socket,
       room_id: room_id,
       player: player,
       engine: engine,
       guess: "",
       answered: MapSet.new(Map.keys(engine.submissions))
     )}
  end

  @impl true
  def handle_event("toggle_ready", _params, socket) do
    RoomServer.set_ready(socket.assigns.room_id, socket.assigns.player.id, !socket.assigns.player.ready)

    {:noreply,
     assign(socket, :player, %{socket.assigns.player | ready: !socket.assigns.player.ready})}
  end

  def handle_event("rename", %{"name" => name}, socket) do
    existing =
      socket.assigns.engine.players
      |> Map.values()
      |> Enum.map(& &1.name)
      |> MapSet.new()

    unique_name = Accounts.ensure_unique_name(name, existing)
    player = %{socket.assigns.player | name: unique_name}
    RoomServer.join(socket.assigns.room_id, player)
    Presence.update(self(), topic(socket.assigns.room_id), player.id, %{name: player.name, ready: player.ready, total_score: 0})

    {:noreply, assign(socket, :player, player)}
  end

  def handle_event("start_game", _params, socket) do
    RoomServer.start_game(socket.assigns.room_id)
    {:noreply, socket}
  end

  def handle_event("submit_guess", %{"guess" => guess}, socket) do
    case RoomServer.submit_answer(socket.assigns.room_id, socket.assigns.player.id, guess) do
      :ok -> {:noreply, assign(socket, guess: "")}
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:phase_changed, _payload}, socket) do
    engine = RoomServer.get_state(socket.assigns.room_id)
    {:noreply, assign(socket, engine: engine, answered: MapSet.new(Map.keys(engine.submissions)))}
  end

  def handle_info({:room_state_updated, _payload}, socket) do
    engine = RoomServer.get_state(socket.assigns.room_id)
    {:noreply, assign(socket, engine: engine)}
  end

  def handle_info({:player_answered, %{player_id: player_id}}, socket) do
    {:noreply, update(socket, :answered, &MapSet.put(&1, player_id))}
  end

  def handle_info({:reveal_posted, _payload}, socket) do
    engine = RoomServer.get_state(socket.assigns.room_id)
    {:noreply, assign(socket, engine: engine)}
  end

  def handle_info({:chat_message_posted, message}, socket) do
    engine = socket.assigns.engine
    chat = %{engine.chat | messages: [message | engine.chat.messages] |> Enum.take(engine.chat.max_messages)}
    {:noreply, assign(socket, engine: %{engine | chat: chat})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="stack">
      <div class="card row">
        <div>
          <h2>Room <%= @room_id %></h2>
          <p class="muted">Phase: <%= @engine.phase %></p>
        </div>
        <div>
          <form phx-submit="rename" class="row">
            <input type="text" name="name" value={@player.name} />
            <button type="submit" class="secondary">Rename</button>
          </form>
        </div>
      </div>

      <div class="grid">
        <div class="stack">
          <%= if @engine.phase == :lobby do %>
            <div class="card stack">
              <h3>Lobby</h3>
              <p class="muted">Players ready: <%= ready_count(@engine.players) %>/<%= map_size(@engine.players) %></p>
              <div>
                <button phx-click="toggle_ready"><%= if @player.ready, do: "Unready", else: "Ready" %></button>
                <button phx-click="start_game" class="secondary">Start game</button>
              </div>
            </div>
          <% else %>
            <div class="card stack">
              <h3>Question</h3>
              <p><%= @engine.current_prompt && @engine.current_prompt.question_text %></p>
              <p class="muted">Ends at: <%= format_time(@engine.round_ends_at) %></p>

              <%= if @engine.phase == :answering do %>
                <form phx-submit="submit_guess" id="guess-form">
                  <div class="row">
                    <input type="text" name="guess" value={@guess} maxlength="80" placeholder="Your answer" autocomplete="off" />
                    <button type="submit">Submit answer</button>
                  </div>
                </form>
                <p class="muted">Answered: <%= MapSet.size(@answered) %>/<%= length(@engine.round_players) %></p>
              <% end %>

              <%= if @engine.phase == :reveal do %>
                <div class="answers">
                  <h4>Reveal</h4>
                  <p>Correct answer: <strong><%= @engine.current_prompt.canonical_answer %></strong></p>
                  <table>
                    <thead>
                      <tr>
                        <th>Player</th>
                        <th>Answer</th>
                        <th>Correct</th>
                        <th>Time (ms)</th>
                        <th>Score</th>
                      </tr>
                    </thead>
                    <tbody>
                      <%= for {player_id, submission} <- @engine.submissions do %>
                        <tr>
                          <td><%= player_name(@engine.players, player_id) %></td>
                          <td><%= submission.answer %></td>
                          <td><%= if submission.correct, do: "✅", else: "❌" %></td>
                          <td><%= submission.elapsed_ms %></td>
                          <td><%= submission.score %></td>
                        </tr>
                      <% end %>
                    </tbody>
                  </table>
                </div>
              <% end %>
            </div>
          <% end %>

          <div class="card stack">
            <h3>Leaderboard</h3>
            <%= for {player_id, score} <- @engine.scores do %>
              <p><%= player_name(@engine.players, player_id) %>: <strong><%= score.total %></strong></p>
            <% end %>
          </div>
        </div>

        <.live_component
          module={ChatComponent}
          id="chat"
          room_id={@room_id}
          player_id={@player.id}
          messages={Enum.reverse(@engine.chat.messages)}
        />
      </div>
    </div>
    """
  end

  defp topic(room_id), do: "room:" <> room_id

  defp format_time(nil), do: "--"
  defp format_time(ms) do
    ms
    |> DateTime.from_unix!(:millisecond)
    |> Calendar.strftime("%H:%M:%S")
  end

  defp ready_count(players) do
    players
    |> Map.values()
    |> Enum.count(& &1.ready)
  end

  defp player_name(players, player_id) do
    case Map.get(players, player_id) do
      nil -> "Unknown"
      player -> player.name
    end
  end
end
