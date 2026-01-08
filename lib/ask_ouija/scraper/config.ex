defmodule AskOuija.Scraper.Config do
  @moduledoc """
  Configuration helpers for the Reddit scraper.
  """

  @default_interval_ms 86_400_000
  @default_limit 100
  @default_subreddit "AskOuija"
  @default_user_agent "ask_ouija_scraper/0.1"
  @default_output_path "priv/data/reddit_prompts.json"

  def enabled? do
    env = System.get_env("REDDIT_SCRAPE_ENABLED")

    case env do
      nil -> config_value(:enabled, false)
      value -> value in ["1", "true", "TRUE", "yes", "YES"]
    end
  end

  def schedule_interval_ms do
    env = System.get_env("REDDIT_SCRAPE_INTERVAL_MS")

    case env do
      nil -> config_value(:schedule_interval_ms, @default_interval_ms)
      value -> parse_int(value, @default_interval_ms)
    end
  end

  def subreddit do
    System.get_env("REDDIT_SUBREDDIT") || config_value(:subreddit, @default_subreddit)
  end

  def limit do
    env = System.get_env("REDDIT_SCRAPE_LIMIT")

    case env do
      nil -> config_value(:limit, @default_limit)
      value -> parse_int(value, @default_limit)
    end
  end

  def user_agent do
    System.get_env("REDDIT_USER_AGENT") || config_value(:user_agent, @default_user_agent)
  end

  def output_path do
    path =
      System.get_env("REDDIT_OUTPUT_PATH") || config_value(:output_path, @default_output_path)

    if Path.type(path) == :relative do
      Application.app_dir(:ask_ouija, path)
    else
      path
    end
  end

  defp config_value(key, default) do
    config = Application.get_env(:ask_ouija, AskOuija.Scraper, [])
    Keyword.get(config, key, default)
  end

  defp parse_int(value, default) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> default
    end
  end
end
