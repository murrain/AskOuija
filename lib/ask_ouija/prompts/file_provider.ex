defmodule AskOuija.Prompts.FileProvider do
  @moduledoc """
  Loads prompts from a JSON file written by the scraper.
  """

  @behaviour AskOuija.Prompts.Provider

  alias AskOuija.Prompts.Prompt

  @impl true
  def next_prompt(%{rng: rng}) do
    prompts = prompts()

    if Enum.empty?(prompts) do
      {index, rng} = :rand.uniform_s(length(AskOuija.Prompts.LocalProvider.prompts()), rng)
      {Enum.at(AskOuija.Prompts.LocalProvider.prompts(), index - 1), rng}
    else
      {index, rng} = :rand.uniform_s(length(prompts), rng)
      {Enum.at(prompts, index - 1), rng}
    end
  end

  def prompts do
    path = file_path()

    with true <- File.exists?(path),
         {:ok, contents} <- File.read(path),
         {:ok, entries} <- Jason.decode(contents) do
      Enum.map(entries, &to_prompt/1)
    else
      _ -> []
    end
  end

  defp file_path do
    config = Application.get_env(:ask_ouija, AskOuija.Prompts, [])
    path = Keyword.get(config, :file_path, "priv/data/reddit_prompts.json")

    if Path.type(path) == :relative do
      Application.app_dir(:ask_ouija, path)
    else
      path
    end
  end

  defp to_prompt(
         %{
           "id" => id,
           "question_text" => question_text,
           "canonical_answer" => canonical_answer
         } = data
       ) do
    %Prompt{
      id: id,
      question_text: question_text,
      canonical_answer: canonical_answer,
      accepted_variants: Map.get(data, "accepted_variants"),
      permalink: Map.get(data, "permalink")
    }
  end
end
