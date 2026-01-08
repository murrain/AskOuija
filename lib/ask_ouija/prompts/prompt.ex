defmodule AskOuija.Prompts.Prompt do
  @moduledoc """
  Struct for a trivia question and canonical answer.
  """

  @type t :: %__MODULE__{
          id: String.t(),
          question_text: String.t(),
          canonical_answer: String.t(),
          accepted_variants: list(String.t()) | nil,
          permalink: String.t() | nil
        }

  defstruct [:id, :question_text, :canonical_answer, :accepted_variants, :permalink]
end
