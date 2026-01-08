defmodule AskOuija.Prompts do
  @moduledoc """
  Prompt selection entry point for the game engine and room server.
  """

  alias AskOuija.Prompts.LocalProvider

  def new_seeded_rng(seed) do
    :rand.seed_s(:exsplus, {seed, seed, seed})
  end

  def provider do
    config = Application.get_env(:ask_ouija, __MODULE__, [])
    Keyword.get(config, :provider, LocalProvider)
  end
end
