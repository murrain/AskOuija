defmodule AskOuija.Prompts.Provider do
  @moduledoc """
  Behaviour for prompt sources.
  """

  alias AskOuija.Prompts.Prompt

  @callback next_prompt(map()) :: {Prompt.t(), any()}
end
