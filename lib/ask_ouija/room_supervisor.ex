defmodule AskOuija.RoomSupervisor do
  @moduledoc """
  Supervises room processes and provides a lookup/start API.
  """
  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_room(room_id) do
    spec = {AskOuija.RoomServer, room_id}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def get_or_start_room(room_id) do
    case Registry.lookup(AskOuija.RoomRegistry, room_id) do
      [{pid, _}] -> {:ok, pid}
      [] -> start_room(room_id)
    end
  end
end
