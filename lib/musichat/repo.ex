defmodule Musichat.Repo do
  use Ecto.Repo,
    otp_app: :musichat,
    adapter: Ecto.Adapters.Postgres
end
