defmodule AskOuijaWeb.RoomLiveTest do
  use AskOuijaWeb.ConnCase, async: false

  alias AskOuija.{RoomServer, RoomSupervisor}

  test "player can join room and chat", %{conn: conn} do
    {:ok, _pid} = RoomSupervisor.get_or_start_room("gamma")

    {:ok, view, _html} = live(conn, "/rooms/gamma")

    assert render(view) =~ "Lobby"

    view
    |> form("#chat-form", %{body: "hello"})
    |> render_submit()

    assert render(view) =~ "hello"
  end

  test "player can submit answer", %{conn: conn} do
    {:ok, _pid} = RoomSupervisor.get_or_start_room("delta")

    {:ok, view, _html} = live(conn, "/rooms/delta")

    RoomServer.start_game("delta")
    pid = via_pid("delta")
    send(pid, :countdown_over)
    Process.sleep(20)

    view
    |> form("#guess-form", %{guess: "Pizza"})
    |> render_submit()

    assert render(view) =~ "Answered: 1/1"
  end

  defp via_pid(room_id) do
    [{pid, _}] = Registry.lookup(AskOuija.RoomRegistry, room_id)
    pid
  end
end
