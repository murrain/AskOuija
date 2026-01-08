defmodule AskOuija.GameEngineTest do
  use ExUnit.Case, async: true

  alias AskOuija.GameEngine
  alias AskOuija.Prompts.Prompt

  test "submission lock prevents second answer" do
    engine = GameEngine.new("room")
    prompt = %Prompt{id: "1", question_text: "Q", canonical_answer: "Yes"}
    engine = GameEngine.start_round(engine, 0, prompt)

    {:ok, engine} = GameEngine.submit_answer(engine, "p1", "Yes", 100)
    assert {:error, :already_submitted} = GameEngine.submit_answer(engine, "p1", "No", 200)
  end

  test "all_answered? returns true when everyone answered" do
    engine = GameEngine.new("room")
    engine = GameEngine.join_player(engine, %{id: "p1"})
    engine = GameEngine.join_player(engine, %{id: "p2"})
    prompt = %Prompt{id: "1", question_text: "Q", canonical_answer: "Yes"}
    engine = GameEngine.start_round(engine, 0, prompt)

    {:ok, engine} = GameEngine.submit_answer(engine, "p1", "Yes", 100)
    {:ok, engine} = GameEngine.submit_answer(engine, "p2", "No", 200)

    assert GameEngine.all_answered?(engine)
  end
end
