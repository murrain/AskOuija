defmodule AskOuija.Prompts.LocalProvider do
  @moduledoc """
  Local trivia dataset used for MVP.
  """

  @behaviour AskOuija.Prompts.Provider

  alias AskOuija.Prompts.Prompt

  @prompts [
    %Prompt{
      id: "1",
      question_text: "What is the largest planet in our solar system?",
      canonical_answer: "Jupiter",
      accepted_variants: ["jupiter"],
      permalink: nil
    },
    %Prompt{
      id: "2",
      question_text: "Which element has the chemical symbol O?",
      canonical_answer: "Oxygen",
      accepted_variants: ["oxygen"],
      permalink: nil
    },
    %Prompt{
      id: "3",
      question_text: "In which year did the first human land on the Moon?",
      canonical_answer: "1969",
      accepted_variants: ["nineteen sixty-nine", "69"],
      permalink: nil
    },
    %Prompt{
      id: "4",
      question_text: "What is the capital city of Japan?",
      canonical_answer: "Tokyo",
      accepted_variants: ["tokyo"],
      permalink: nil
    },
    %Prompt{
      id: "5",
      question_text: "How many continents are there on Earth?",
      canonical_answer: "Seven",
      accepted_variants: ["7", "seven"],
      permalink: nil
    },
    %Prompt{
      id: "6",
      question_text: "What is the tallest land animal?",
      canonical_answer: "Giraffe",
      accepted_variants: ["giraffe"],
      permalink: nil
    },
    %Prompt{
      id: "7",
      question_text: "Which ocean is the largest by surface area?",
      canonical_answer: "Pacific Ocean",
      accepted_variants: ["pacific", "pacific ocean"],
      permalink: nil
    },
    %Prompt{
      id: "8",
      question_text: "What instrument has 88 keys?",
      canonical_answer: "Piano",
      accepted_variants: ["piano"],
      permalink: nil
    },
    %Prompt{
      id: "9",
      question_text: "What is the fastest land animal?",
      canonical_answer: "Cheetah",
      accepted_variants: ["cheetah"],
      permalink: nil
    },
    %Prompt{
      id: "10",
      question_text: "Which planet is known as the Red Planet?",
      canonical_answer: "Mars",
      accepted_variants: ["mars"],
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
