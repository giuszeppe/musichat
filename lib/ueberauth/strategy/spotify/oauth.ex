defmodule Ueberauth.Strategy.Spotify.OAuth do
  use OAuth2.Strategy


  @defaults [
    strategy: __MODULE__,
    site: "https://open.spotify.com/",
    authorize_url: "https://accounts.spotify.com/authorize",
    token_url: "https://accounts.spotify.com/api/token",
    redirect_uri: "http://localhost:4000/auth/spotify/callback",
    token_method: :post,
    scope: "playlist-read-private"
  ]

  def client(opts \\ []) do
    # This is where we grab the CLient ID and Client Secret we created earilier
    config =
      :ueberauth
      |> Application.fetch_env!(Ueberauth.Strategy.Spotify.OAuth)
      |> check_config_key_exists(:client_id)
      |> check_config_key_exists(:client_secret)

    client_opts =
      @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)

    json_library = Ueberauth.json_library()

    OAuth2.Client.new(client_opts)
    |> OAuth2.Client.put_serializer("application/json", json_library)
    |> OAuth2.Client.put_serializer("application/vnd.api+json", json_library)
  end

  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)

  end

  def authorize_url(client,params) do
    OAuth2.Strategy.AuthCode.authorize_url(client,params)
  end

  defp check_config_key_exists(config,key) when is_list(config) do
    unless Keyword.has_key?(config,key) do
      raise "#{inspect(key)} missing from config :ueberauth, Ueberauth.Strategy.Spotify"
    end

    config
  end

  defp check_config_key_exists(_, _) do
    raise "Config :ueberauth, Ueberauth.Strategy.Patreon is not a keyword list, as expected"
  end

  def get_token!(params \\ [], options \\ []) do
    headers = Keyword.get(options,:headers,[])
    options = Keyword.get(options,:options,[])

    client_options = Keyword.get(options,:client_options, [])
    client = OAuth2.Client.get_token!(client(client_options), params, headers, options)
    client.token

  end

  def get_token(client, params, headers) do
    client = client
    |> put_param("grant_type", "authorization_code")
    |> put_header("Accept", "application/json")

    OAuth2.Strategy.AuthCode.get_token(client, params, headers)
  end

end
