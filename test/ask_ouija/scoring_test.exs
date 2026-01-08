defmodule AskOuija.ScoringTest do
  use ExUnit.Case, async: true

  alias AskOuija.Scoring
  alias AskOuija.Prompts.Prompt

  test "fast correct answers score higher than slow" do
    prompt = %Prompt{id: "1", question_text: "Q", canonical_answer: "Yes"}
    settings = %{scoring_mode: :strict_exact, base_correct_points: 100, min_correct_points: 10}

    fast = Scoring.score_answer("Yes", prompt, 1_000, 30_000, settings)
    slow = Scoring.score_answer("Yes", prompt, 25_000, 30_000, settings)

    assert fast > slow
  end

  test "fuzzy scoring grants partial credit" do
    prompt = %Prompt{id: "1", question_text: "Q", canonical_answer: "pizza"}
    settings = %{scoring_mode: :fuzzy_similarity, base_correct_points: 100, min_correct_points: 10}

    score = Scoring.score_answer("piza", prompt, 5_000, 30_000, settings)

    assert score > 0
  end
end
