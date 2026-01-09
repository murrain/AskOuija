defmodule AskOuijaWeb.HomeLiveTest do
  use AskOuijaWeb.ConnCase, async: true

  test "create room navigates to a new room", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("button", "Create room")
    |> render_click()

    assert_redirect(view, ~r"/rooms/[a-z0-9_-]+")
  end

  test "join requires a room code", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> form("form[phx-submit='join']", %{room: ""})
    |> render_submit()

    assert render(view) =~ "Enter a room code to join."
  end

  test "join navigates to the provided room", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> form("form[phx-submit='join']", %{room: "Alpha"})
    |> render_submit()

    assert_redirect(view, "/rooms/alpha")
  end
end
