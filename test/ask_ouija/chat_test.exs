defmodule AskOuija.ChatTest do
  use ExUnit.Case, async: true

  alias AskOuija.Chat

  test "rate limiting prevents rapid messages" do
    chat = Chat.new(5)

    {:ok, chat, _message} = Chat.post(chat, "p1", "Player", "hello", 1_000)
    assert {:error, :rate_limited} = Chat.post(chat, "p1", "Player", "again", 1_500)
  end

  test "messages are stored newest first" do
    chat = Chat.new(5)

    {:ok, chat, _} = Chat.post(chat, "p1", "Player", "first", 1_000)
    {:ok, chat, _} = Chat.post(chat, "p1", "Player", "second", 2_000)

    assert [%{body: "second"}, %{body: "first"}] = chat.messages
  end
end
