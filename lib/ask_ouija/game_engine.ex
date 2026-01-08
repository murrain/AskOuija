defmodule AskOuija.GameEngine do
  @moduledoc """
  Pure game state transitions and scoring logic.
  """

  alias AskOuija.{Chat, Prompts, Scoring}

  defstruct [
    :room_id,
    :settings,
    :phase,
    :current_prompt,
    :round_started_at,
    :round_ends_at,
    :rng,
    submissions: %{},
    scores: %{},
    players: %{},
    round_players: [],
    chat: %Chat{},
    history: []
  ]

  def default_settings do
    %{
      round_time_seconds: 30,
      countdown_seconds: 3,
      intermission_seconds: 5,
      number_of_rounds: 5,
      endless: false,
      scoring_mode: :strict,
      base_correct_points: 100,
      min_correct_points: 10,
      first_correct_bonus: 20,
      prompts_source: :local,
      late_join_behavior: :spectate_until_next_round,
      max_players: 8,
      allow_edits: false
    }
  end

  def new(room_id, seed \\ System.system_time(:millisecond)) do
    %__MODULE__{
      room_id: room_id,
      settings: default_settings(),
      phase: :lobby,
      rng: Prompts.new_seeded_rng(seed),
      chat: Chat.new()
    }
  end

  def join_player(state, player) do
    players = Map.put(state.players, player.id, player)
    %{state | players: players}
  end

  def leave_player(state, player_id) do
    %{state | players: Map.delete(state.players, player_id)}
  end

  def set_ready(state, player_id, ready) do
    update_in(state.players[player_id], fn
      nil -> nil
      player -> Map.put(player, :ready, ready)
    end)
  end

  def update_settings(state, settings) do
    %{state | settings: Map.merge(state.settings, settings)}
  end

  def start_countdown(state, now_ms) do
    %{state | phase: :countdown, round_started_at: now_ms, round_ends_at: now_ms + state.settings.countdown_seconds * 1000}
  end

  def start_round(state, now_ms, prompt) do
    round_duration_ms = state.settings.round_time_seconds * 1000

    %{
      state
      | phase: :answering,
        current_prompt: prompt,
        round_started_at: now_ms,
        round_ends_at: now_ms + round_duration_ms,
        submissions: %{},
        round_players: Map.keys(state.players)
    }
  end

  def submit_answer(state, player_id, answer, now_ms) do
    cond do
      state.phase != :answering ->
        {:error, :not_accepting}

      Map.has_key?(state.submissions, player_id) and not state.settings.allow_edits ->
        {:error, :already_submitted}

      String.trim(answer) == "" ->
        {:error, :invalid}

      String.length(answer) > 80 ->
        {:error, :too_long}

      true ->
        elapsed_ms = max(now_ms - state.round_started_at, 0)

        submission = %{
          answer: String.trim(answer),
          submitted_at: now_ms,
          elapsed_ms: elapsed_ms
        }

        submissions = Map.put(state.submissions, player_id, submission)
        {:ok, %{state | submissions: submissions}}
    end
  end

  def all_answered?(state) do
    Enum.all?(state.round_players, &Map.has_key?(state.submissions, &1))
  end

  def reveal(state) do
    round_duration_ms = state.settings.round_time_seconds * 1000

    {scored, first_correct} =
      state.submissions
      |> Enum.map(fn {player_id, submission} ->
        score =
          Scoring.score_answer(
            submission.answer,
            state.current_prompt,
            submission.elapsed_ms,
            round_duration_ms,
            state.settings
          )

        {player_id, Map.put(submission, :score, score)}
      end)
      |> Enum.sort_by(fn {_player_id, submission} -> submission.elapsed_ms end)
      |> Enum.reduce({%{}, nil}, fn {player_id, submission}, {acc, first_correct} ->
        is_correct = Scoring.correct?(submission.answer, state.current_prompt)

        {score, first_correct} =
          if is_correct and first_correct == nil do
            {submission.score + state.settings.first_correct_bonus, player_id}
          else
            {submission.score, first_correct}
          end

        {Map.put(acc, player_id, Map.merge(submission, %{correct: is_correct, score: score})), first_correct}
      end)

    scores =
      Enum.reduce(scored, state.scores, fn {player_id, submission}, acc ->
        current = Map.get(acc, player_id, %{total: 0, answers: 0, total_time_ms: 0})

        updated = %{
          total: current.total + submission.score,
          answers: current.answers + 1,
          total_time_ms: current.total_time_ms + submission.elapsed_ms
        }

        Map.put(acc, player_id, updated)
      end)

    %{state | phase: :reveal, submissions: scored, scores: scores}
  end

  def start_intermission(state, now_ms) do
    %{state | phase: :intermission, round_started_at: now_ms, round_ends_at: now_ms + state.settings.intermission_seconds * 1000}
  end
end
