defmodule AskOuijaWeb.Plugs.AssignPlayer do
  @moduledoc false
  import Plug.Conn

  alias AskOuija.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_session(conn)

    case get_session(conn, :player_id) do
      nil ->
        guest = Accounts.generate_guest(System.unique_integer([:positive]))

        conn
        |> put_session(:player_id, guest.id)
        |> put_session(:player_name, guest.name)
        |> put_session(:avatar_seed, guest.avatar_seed)

      _ ->
        conn
    end
  end
end
