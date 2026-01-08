defmodule AskOuija.Scoring do
  @moduledoc """
  Scoring helpers for speed trivia rounds.
  """

  def normalize(answer) do
    answer
    |> String.trim()
    |> String.downcase()
    |> String.replace(~r/[^\p{L}\p{N}\s]/u, "")
    |> String.replace(~r/\s+/, " ")
  end

  def correct?(answer, prompt) do
    normalized = normalize(answer)
    canonical = normalize(prompt.canonical_answer)
    variants = (prompt.accepted_variants || []) |> Enum.map(&normalize/1)

    normalized == canonical or normalized in variants
  end

  def similarity(answer, prompt) do
    normalized = normalize(answer)
    canonical = normalize(prompt.canonical_answer)
    String.jaro_distance(normalized, canonical)
  end

  def score_answer(answer, prompt, elapsed_ms, round_duration_ms, settings) do
    time_factor = max(0.0, 1 - elapsed_ms / max(round_duration_ms, 1))
    base = settings.base_correct_points
    min_points = settings.min_correct_points

    cond do
      correct?(answer, prompt) ->
        score = trunc(base * time_factor)
        clamp(score, min_points, base)

      settings.scoring_mode == :fuzzy ->
        similarity_score = similarity(answer, prompt)
        trunc(base * similarity_score * time_factor)

      true ->
        0
    end
  end

  defp clamp(value, min, max) do
    value
    |> max(min)
    |> min(max)
  end
end
