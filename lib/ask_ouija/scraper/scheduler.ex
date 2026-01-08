defmodule AskOuija.Scraper.Scheduler do
  @moduledoc """
  Periodically runs the Reddit scraper.
  """

  use GenServer
  require Logger

  alias AskOuija.Scraper.Config
  alias AskOuija.Scraper.Reddit

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    schedule_next()
    {:ok, state}
  end

  @impl true
  def handle_info(:scrape, state) do
    case Reddit.scrape() do
      {:ok, count, path} ->
        Logger.info("Reddit scrape stored #{count} prompts at #{path}")

      {:error, reason} ->
        Logger.warning("Reddit scrape failed: #{inspect(reason)}")
    end

    schedule_next()
    {:noreply, state}
  end

  defp schedule_next do
    Process.send_after(self(), :scrape, Config.schedule_interval_ms())
  end
end
