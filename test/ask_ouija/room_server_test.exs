defmodule AskOuija.RoomServerTest do
  use ExUnit.Case

  alias AskOuija.{RoomServer, RoomSupervisor}

  test "reveal happens early when all players answered" do
    {:ok, _pid} = RoomSupervisor.get_or_start_room("alpha")

    RoomServer.join("alpha", %{id: "p1", name: "One"})
    RoomServer.join("alpha", %{id: "p2", name: "Two"})
    RoomServer.start_game("alpha")

    pid = via_pid("alpha")
    send(pid, :countdown_over)
    Process.sleep(10)

    RoomServer.submit_answer("alpha", "p1", "Pizza")
    RoomServer.submit_answer("alpha", "p2", "Love")

    engine = RoomServer.get_state("alpha")
    assert engine.phase == :reveal
  end

  test "reveal happens when timer expires" do
    {:ok, _pid} = RoomSupervisor.get_or_start_room("beta")

    RoomServer.join("beta", %{id: "p1", name: "One"})
    RoomServer.start_game("beta")

    pid = via_pid("beta")
    send(pid, :countdown_over)
    Process.sleep(10)

    send(pid, :reveal_over)
    Process.sleep(10)

    engine = RoomServer.get_state("beta")
    assert engine.phase == :reveal
  end

  defp via_pid(room_id) do
    [{pid, _}] = Registry.lookup(AskOuija.RoomRegistry, room_id)
    pid
  end
end
