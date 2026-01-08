defmodule AskOuija.Prompts.Prompt do
  @moduledoc """
  Struct for a prompt question and canonical answer.
  """

  defstruct [:id, :question_text, :canonical_answer, :accepted_variants, :permalink]
end
