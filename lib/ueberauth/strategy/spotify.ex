defmodule Ueberauth.Strategy.Spotify do
  use Ueberauth.Strategy,
    oauth2_module: Ueberauth.Strategy.Spotify.OAuth

  alias Ueberauth.Auth.Credentials

  def handle_request!(conn) do
    params =
      [scope: "user-read-email user-top-read"]
      |> with_state_param(conn)
     # Will invoke the OAuth Spotify module we will define next

    module = option(conn, :oauth2_module)
     # Performs the redirect to Patreon to REQUEST access
    redirect!(conn,apply(module,:authorize_url!, [params]))
  end

  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    module = option(conn, :oauth2_module)
    # Uses our oauth module to perform the token fetch
    token = apply(module, :get_token!, [[code: code]])

    if token.access_token == nil do
      set_errors!(conn, [
        error(token.other_params["error"], token.other_params["error_description"])
      ])
    else
      conn
      |> put_private( :spotify_token, token)
    end
  end

  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  def handle_cleanup!(conn) do
    conn
    |> put_private(:spotify_token, nil)
  end


  def credentials(conn) do
    token = conn.private.spotify_token

    %Credentials{
      token: token.access_token,
      token_type: token.token_type,
      refresh_token: token.refresh_token,
      expires_at: token.expires_at
    }
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end
end
