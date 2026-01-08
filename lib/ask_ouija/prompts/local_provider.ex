defmodule AskOuija.Prompts.LocalProvider do
  @moduledoc """
  Local prompt dataset used for MVP.
  """

  @behaviour AskOuija.Prompts.Provider

  alias AskOuija.Prompts.Prompt

  @prompts [
    %Prompt{
      id: "1",
      question_text: "Ouija, what is the best snack for a late-night study session?",
      canonical_answer: "Pizza",
      accepted_variants: ["PIZZA", "pizza"],
      permalink: nil
    },
    %Prompt{
      id: "2",
      question_text: "Ouija, what is the secret ingredient in grandma's cookies?",
      canonical_answer: "Love",
      accepted_variants: ["love", "L0VE"],
      permalink: nil
    },
    %Prompt{
      id: "3",
      question_text: "Ouija, what will my cat demand at 3 AM?",
      canonical_answer: "Food",
      accepted_variants: ["Food", "food", "FEED ME"],
      permalink: nil
    },
    %Prompt{
      id: "4",
      question_text: "Ouija, what is the worst thing to find in the fridge?",
      canonical_answer: "Mold",
      accepted_variants: ["mold", "MOLD"],
      permalink: nil
    },
    %Prompt{
      id: "5",
      question_text: "Ouija, what should I name my new ship?",
      canonical_answer: "Nebula",
      accepted_variants: ["nebula"],
      permalink: nil
    },
    %Prompt{
      id: "6",
      question_text: "Ouija, what will we discover on Mars?",
      canonical_answer: "Water",
      accepted_variants: ["H2O", "water"],
      permalink: nil
    },
    %Prompt{
      id: "7",
      question_text: "Ouija, what is the best karaoke song?",
      canonical_answer: "Bohemian Rhapsody",
      accepted_variants: ["bohemian rhapsody", "Bohemian"],
      permalink: nil
    },
    %Prompt{
      id: "8",
      question_text: "Ouija, what happens if you press the red button?",
      canonical_answer: "Explosion",
      accepted_variants: ["boom", "explosion"],
      permalink: nil
    },
    %Prompt{
      id: "9",
      question_text: "Ouija, what will I win in the arcade?",
      canonical_answer: "Tickets",
      accepted_variants: ["tickets", "ticket"],
      permalink: nil
    },
    %Prompt{
      id: "10",
      question_text: "Ouija, what should I bring to the haunted picnic?",
      canonical_answer: "Blanket",
      accepted_variants: ["blanket", "a blanket"],
      permalink: nil
    }
  ]

  @impl true
  def next_prompt(%{rng: rng}) do
    {index, rng} = :rand.uniform_s(length(@prompts), rng)
    {Enum.at(@prompts, index - 1), rng}
  end

  def prompts, do: @prompts
end
