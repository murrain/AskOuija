ExUnit.start()

{:ok, _} = Application.ensure_all_started(:logger)
{:ok, _} = Application.ensure_all_started(:phoenix)
{:ok, _} = Application.ensure_all_started(:phoenix_pubsub)
{:ok, _} = Application.ensure_all_started(:phoenix_live_view)
{:ok, _} = Application.ensure_all_started(:ask_ouija)
