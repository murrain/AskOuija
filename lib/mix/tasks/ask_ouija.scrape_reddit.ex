defmodule Mix.Tasks.AskOuija.ScrapeReddit do
  @moduledoc "Scrape Reddit prompts and write them to disk."

  use Mix.Task

  alias AskOuija.Scraper.Reddit

  @shortdoc "Scrape Reddit prompts into the configured output file"
  def run(_args) do
    Mix.Task.run("app.config")

    case Reddit.scrape() do
      {:ok, count, path} ->
        Mix.shell().info("Stored #{count} prompts at #{path}")

      {:error, reason} ->
        Mix.raise("Reddit scrape failed: #{inspect(reason)}")
    end
  end
end
