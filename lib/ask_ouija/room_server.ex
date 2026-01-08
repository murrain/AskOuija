defmodule AskOuija.RoomServer do
  @moduledoc false

  use GenServer

  alias AskOuija.{Chat, GameEngine, Prompts}

  @topic_prefix "room:"

  def start_link(room_id) do
    GenServer.start_link(__MODULE__, room_id, name: via(room_id))
  end

  def via(room_id), do: {:via, Registry, {AskOuija.RoomRegistry, room_id}}

  def join(room_id, player) do
    GenServer.call(via(room_id), {:join, player})
  end

  def leave(room_id, player_id) do
    GenServer.call(via(room_id), {:leave, player_id})
  end

  def set_ready(room_id, player_id, ready) do
    GenServer.call(via(room_id), {:set_ready, player_id, ready})
  end

  def update_settings(room_id, settings) do
    GenServer.call(via(room_id), {:update_settings, settings})
  end

  def start_game(room_id) do
    GenServer.call(via(room_id), :start_game)
  end

  def submit_answer(room_id, player_id, answer) do
    GenServer.call(via(room_id), {:submit_answer, player_id, answer})
  end

  def post_chat_message(room_id, player_id, body) do
    GenServer.call(via(room_id), {:post_chat_message, player_id, body})
  end

  def force_reveal(room_id) do
    GenServer.call(via(room_id), :force_reveal)
  end

  def get_state(room_id) do
    GenServer.call(via(room_id), :get_state)
  end

  @impl true
  def init(room_id) do
    {:ok, %{engine: GameEngine.new(room_id), round: 0, timers: %{}, room_id: room_id}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state.engine, state}
  end

  def handle_call({:join, player}, _from, state) do
    engine = GameEngine.join_player(state.engine, player)
    {chat, message} = Chat.system_message(engine.chat, "#{player.name} joined the room", now_ms())
    engine = %{engine | chat: chat}
    broadcast(state.room_id, :player_joined, %{player: player})
    broadcast(state.room_id, :chat_message_posted, message)
    {:reply, {:ok, engine}, %{state | engine: engine}}
  end

  def handle_call({:leave, player_id}, _from, state) do
    player = state.engine.players[player_id]
    engine = GameEngine.leave_player(state.engine, player_id)
    {chat, message} = Chat.system_message(engine.chat, "#{player&.name || "A player"} left the room", now_ms())
    engine = %{engine | chat: chat}
    broadcast(state.room_id, :player_left, %{player_id: player_id})
    broadcast(state.room_id, :chat_message_posted, message)
    {:reply, :ok, %{state | engine: engine}}
  end

  def handle_call({:set_ready, player_id, ready}, _from, state) do
    engine = GameEngine.set_ready(state.engine, player_id, ready)
    broadcast(state.room_id, :room_state_updated, %{phase: engine.phase, players: engine.players})
    {:reply, :ok, %{state | engine: engine}}
  end

  def handle_call({:update_settings, settings}, _from, state) do
    engine = GameEngine.update_settings(state.engine, settings)
    broadcast(state.room_id, :room_state_updated, %{settings: engine.settings})
    {:reply, :ok, %{state | engine: engine}}
  end

  def handle_call(:start_game, _from, state) do
    now = now_ms()
    engine = GameEngine.start_countdown(state.engine, now)
    state = schedule_timer(state, :countdown, engine.round_ends_at - now)
    broadcast(state.room_id, :phase_changed, %{phase: engine.phase, round_ends_at: engine.round_ends_at})
    {:reply, :ok, %{state | engine: engine, round: 1}}
  end

  def handle_call({:submit_answer, player_id, answer}, _from, state) do
    now = now_ms()

    case GameEngine.submit_answer(state.engine, player_id, answer, now) do
      {:ok, engine} ->
        broadcast(state.room_id, :player_answered, %{player_id: player_id})

        if GameEngine.all_answered?(engine) do
          state = cancel_timer(state, :reveal)
          engine = GameEngine.reveal(engine)
          state = schedule_timer(state, :intermission, engine.settings.intermission_seconds * 1000)
          broadcast_reveal(state.room_id, engine)
          {:reply, :ok, %{state | engine: engine}}
        else
          {:reply, :ok, %{state | engine: engine}}
        end

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:post_chat_message, player_id, body}, _from, state) do
    player = state.engine.players[player_id]

    if player do
      case Chat.post(state.engine.chat, player_id, player.name, body, now_ms()) do
        {:ok, chat, message} ->
          engine = %{state.engine | chat: chat}
          broadcast(state.room_id, :chat_message_posted, message)
          {:reply, :ok, %{state | engine: engine}}

        {:error, reason} ->
          {:reply, {:error, reason}, state}
      end
    else
      {:reply, {:error, :unknown_player}, state}
    end
  end

  def handle_call(:force_reveal, _from, state) do
    state = cancel_timer(state, :reveal)
    engine = GameEngine.reveal(state.engine)
    state = schedule_timer(state, :intermission, engine.settings.intermission_seconds * 1000)
    broadcast_reveal(state.room_id, engine)
    {:reply, :ok, %{state | engine: engine}}
  end

  @impl true
  def handle_info(:countdown_over, state) do
    now = now_ms()
    {prompt, rng} = Prompts.provider().next_prompt(%{rng: state.engine.rng})
    engine = GameEngine.start_round(state.engine, now, prompt)
    engine = %{engine | rng: rng}
    state = schedule_timer(state, :reveal, engine.round_ends_at - now)
    broadcast(state.room_id, :phase_changed, %{phase: engine.phase, round_ends_at: engine.round_ends_at, prompt: prompt})
    {:noreply, %{state | engine: engine}}
  end

  def handle_info(:reveal_over, state) do
    engine = GameEngine.reveal(state.engine)
    state = schedule_timer(state, :intermission, engine.settings.intermission_seconds * 1000)
    broadcast_reveal(state.room_id, engine)
    {:noreply, %{state | engine: engine}}
  end

  def handle_info(:intermission_over, state) do
    if state.engine.settings.endless or state.round < state.engine.settings.number_of_rounds do
      now = now_ms()
      {prompt, rng} = Prompts.provider().next_prompt(%{rng: state.engine.rng})
      engine = GameEngine.start_round(state.engine, now, prompt)
      engine = %{engine | rng: rng}
      state = schedule_timer(state, :reveal, engine.round_ends_at - now)
      broadcast(state.room_id, :phase_changed, %{phase: engine.phase, round_ends_at: engine.round_ends_at, prompt: prompt})
      {:noreply, %{state | engine: engine, round: state.round + 1}}
    else
      engine = %{state.engine | phase: :lobby}
      broadcast(state.room_id, :phase_changed, %{phase: engine.phase})
      {:noreply, %{state | engine: engine}}
    end
  end

  defp broadcast(room_id, event, payload) do
    Phoenix.PubSub.broadcast(AskOuija.PubSub, topic(room_id), {event, payload})
  end

  defp broadcast_reveal(room_id, engine) do
    broadcast(room_id, :reveal_posted, %{
      prompt: engine.current_prompt,
      submissions: engine.submissions,
      scores: engine.scores
    })
  end

  defp topic(room_id), do: @topic_prefix <> room_id

  defp schedule_timer(state, name, delay_ms) do
    ref = Process.send_after(self(), timer_message(name), max(delay_ms, 0))
    %{state | timers: Map.put(state.timers, name, ref)}
  end

  defp cancel_timer(state, name) do
    case Map.get(state.timers, name) do
      nil -> state
      ref ->
        Process.cancel_timer(ref)
        %{state | timers: Map.delete(state.timers, name)}
    end
  end

  defp timer_message(:countdown), do: :countdown_over
  defp timer_message(:reveal), do: :reveal_over
  defp timer_message(:intermission), do: :intermission_over

  defp now_ms, do: System.system_time(:millisecond)
end
