defmodule AskOuija.Scraper.Reddit do
  @moduledoc """
  Scrapes Reddit posts and writes prompts to disk.
  """

  require Logger

  alias AskOuija.Prompts.Prompt
  alias AskOuija.Scraper.Config

  @base_url "https://www.reddit.com"

  def scrape(opts \\ []) do
    config = Keyword.merge(default_options(), opts)

    with :ok <- ensure_http_clients(),
         {:ok, listing} <- fetch_listing(config),
         prompts <- listing_to_prompts(listing),
         :ok <- write_prompts(prompts, config) do
      {:ok, length(prompts), config[:output_path]}
    end
  end

  defp default_options do
    [
      subreddit: Config.subreddit(),
      limit: Config.limit(),
      user_agent: Config.user_agent(),
      output_path: Config.output_path()
    ]
  end

  defp ensure_http_clients do
    with :ok <- normalize_start_result(Application.ensure_all_started(:inets)),
         :ok <- normalize_start_result(Application.ensure_all_started(:ssl)) do
      :ok
    end
  end

  defp normalize_start_result({:ok, _apps}), do: :ok
  defp normalize_start_result({:error, {:already_started, _app}}), do: :ok
  defp normalize_start_result(:ok), do: :ok
  defp normalize_start_result(other), do: other

  defp fetch_listing(config) do
    url =
      "#{@base_url}/r/#{config[:subreddit]}/new.json?limit=#{config[:limit]}"

    headers = [{~c"User-Agent", to_charlist(config[:user_agent])}]

    case :httpc.request(:get, {to_charlist(url), headers}, [], []) do
      {:ok, {{_, 200, _}, _headers, body}} ->
        body
        |> to_string()
        |> Jason.decode()

      {:ok, {{_, status, _}, _headers, body}} ->
        Logger.warning("Reddit scrape failed with status #{status}: #{inspect(body)}")
        {:error, :http_error}

      {:error, reason} ->
        Logger.warning("Reddit scrape failed with #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp listing_to_prompts(%{"data" => %{"children" => children}}) do
    children
    |> Enum.map(& &1["data"])
    |> Enum.reduce([], fn post, acc ->
      with question when is_binary(question) <- extract_question(post["selftext"]),
           answer when is_binary(answer) <- extract_answer(post["link_flair_text"]),
           id when is_binary(id) <- post["id"] do
        prompt = %Prompt{
          id: "reddit-#{id}",
          question_text: question,
          canonical_answer: answer,
          accepted_variants: [normalize_answer(answer)],
          permalink: permalink(post["permalink"])
        }

        [prompt | acc]
      else
        _ -> acc
      end
    end)
    |> Enum.reverse()
  end

  defp listing_to_prompts(_), do: []

  defp extract_question(nil), do: nil

  defp extract_question(selftext) do
    selftext
    |> String.split(~r/\r?\n/, trim: true)
    |> Enum.find(&(&1 != ""))
    |> case do
      nil -> nil
      line -> line |> String.replace(~r/^\s*Q:\s*/i, "") |> String.trim()
    end
    |> case do
      "" -> nil
      value -> value
    end
  end

  defp extract_answer(nil), do: nil

  defp extract_answer(text) do
    text
    |> String.trim()
    |> case do
      "" -> nil
      value -> value
    end
  end

  defp normalize_answer(answer) do
    answer
    |> String.downcase()
    |> String.trim()
  end

  defp permalink(nil), do: nil
  defp permalink(path), do: @base_url <> path

  defp write_prompts(prompts, config) do
    output_path = config[:output_path]
    output_dir = Path.dirname(output_path)

    File.mkdir_p!(output_dir)

    payload =
      prompts
      |> Enum.map(&prompt_to_map/1)
      |> Jason.encode!(pretty: true)

    File.write(output_path, payload)
  end

  defp prompt_to_map(%Prompt{} = prompt) do
    %{
      id: prompt.id,
      question_text: prompt.question_text,
      canonical_answer: prompt.canonical_answer,
      accepted_variants: prompt.accepted_variants,
      permalink: prompt.permalink
    }
  end
end
