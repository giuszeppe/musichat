defmodule MusichatWeb.AuthController do
  use MusichatWeb, :controller
  alias MusichatWeb.UserAuth
  alias Musichat.Accounts
  plug Ueberauth

  @rand_pass_length 32

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  # Successful callback OAuth phase
  def callback(%{assigns: %{ueberauth_auth: %{provider: :spotify, info: user_info} = auth}} = conn, _params) do
    user_email = HTTPoison.get!("https://api.spotify.com/v1/me",%{authorization: "Bearer #{auth.credentials.token}"})
    |> Map.get(:body)
    |> Jason.decode!()
    |> Map.get("email")
    |> IO.inspect()
    user_params = %{email: user_email, password: random_password()}
    case Accounts.fetch_or_create_user(user_params) do
      {:ok, user} ->
        UserAuth.log_in_user(conn, user)
        _ ->
        conn
        |> put_flash(:error, "Authentication failed")
        |> redirect(to: "/")
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:access_token)
  end

  defp random_password do
    :crypto.strong_rand_bytes(@rand_pass_length) |> Base.encode64()
  end
end
