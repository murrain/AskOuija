defmodule AskOuija.Accounts do
  @moduledoc """
  Lightweight guest identity and stats tracking.
  """

  @adjectives ~w(Curious Spooky Silly Bright Clever Swift Ancient Lucky Mysterious)
  @nouns ~w(Oracle Spirit Whisper Echo Lantern Raven Wanderer Mirror)

  def generate_guest(seed \ System.system_time(:millisecond)) do
    {adj, noun} = name_from_seed(seed)
    %{id: "guest_#{seed}", name: "#{adj} #{noun}", avatar_seed: Integer.to_string(seed)}
  end

  def ensure_unique_name(desired, existing_names) do
    base = String.trim(desired)

    if base == "" do
      unique_name("Guest", existing_names)
    else
      unique_name(base, existing_names)
    end
  end

  defp unique_name(base, existing_names) do
    if MapSet.member?(existing_names, base) do
      suffix = Enum.count(existing_names, &String.starts_with?(&1, base)) + 1
      "#{base} #{suffix}"
    else
      base
    end
  end

  defp name_from_seed(seed) do
    adjective = Enum.at(@adjectives, rem(seed, length(@adjectives)))
    noun = Enum.at(@nouns, rem(div(seed, 3), length(@nouns)))
    {adjective, noun}
  end
end
