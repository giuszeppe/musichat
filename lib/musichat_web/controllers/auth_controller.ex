defmodule MusichatWeb.AuthController do
  use MusichatWeb, :controller

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  # Successful callback OAuth phase
  def callback(%{assigns: %{ueberauth_auth: %{provider: :spotify} = auth}} = conn, _params) do
    IO.inspect(conn)
    IO.inspect(auth)
    conn
    |> redirect(to: "/")
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:access_token)
  end
end
