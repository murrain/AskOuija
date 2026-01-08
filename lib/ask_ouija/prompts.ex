defmodule AskOuija.Prompts do
  @moduledoc false

  alias AskOuija.Prompts.LocalProvider

  def new_seeded_rng(seed) do
    :rand.seed_s(:exsplus, {seed, seed, seed})
  end

  def provider, do: LocalProvider
end
