defmodule AskOuija.PromptsTest do
  use ExUnit.Case, async: true

  alias AskOuija.Prompts

  test "seeded prompt selection is deterministic" do
    rng1 = Prompts.new_seeded_rng(42)
    rng2 = Prompts.new_seeded_rng(42)

    {prompt1, rng1} = Prompts.provider().next_prompt(%{rng: rng1})
    {prompt2, _rng1} = Prompts.provider().next_prompt(%{rng: rng1})

    {prompt1b, rng2} = Prompts.provider().next_prompt(%{rng: rng2})
    {prompt2b, _rng2} = Prompts.provider().next_prompt(%{rng: rng2})

    assert prompt1.id == prompt1b.id
    assert prompt2.id == prompt2b.id
  end
end
