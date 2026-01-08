defmodule AskOuija.Chat do
  @moduledoc """
  In-memory chat message storage with validation and rate limiting.
  """

  defstruct messages: [], max_messages: 200, last_sent_at: %{}

  @type t :: %__MODULE__{}

  def new(max_messages \\ 200) do
    %__MODULE__{max_messages: max_messages}
  end

  def post(%__MODULE__{} = chat, player_id, player_name, body, now_ms) do
    trimmed = body |> String.trim() |> String.slice(0, 240)

    with true <- trimmed != "",
         true <- allowed_to_send?(chat, player_id, now_ms) do
      message = %{
        id: "msg_#{now_ms}_#{player_id}",
        player_id: player_id,
        player_name: player_name,
        body: trimmed,
        inserted_at: now_ms,
        kind: :player
      }

      {:ok, store_message(chat, message, now_ms), message}
    else
      false -> {:error, :invalid}
      {:error, reason} -> {:error, reason}
    end
  end

  def system_message(%__MODULE__{} = chat, body, now_ms) do
    message = %{
      id: "sys_#{now_ms}",
      player_id: nil,
      player_name: "System",
      body: body,
      inserted_at: now_ms,
      kind: :system
    }

    {store_message(chat, message, now_ms), message}
  end

  defp allowed_to_send?(%__MODULE__{last_sent_at: last_sent_at}, player_id, now_ms) do
    case Map.get(last_sent_at, player_id) do
      nil -> true
      last when now_ms - last >= 1000 -> true
      _ -> {:error, :rate_limited}
    end
  end

  defp store_message(%__MODULE__{} = chat, message, now_ms) do
    messages = [message | chat.messages] |> Enum.take(chat.max_messages)

    %__MODULE__{chat | messages: messages, last_sent_at: Map.put(chat.last_sent_at, message.player_id, now_ms)}
  end
end
