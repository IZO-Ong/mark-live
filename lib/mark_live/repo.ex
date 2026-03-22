defmodule MarkLive.Repo do
  use Ecto.Repo,
    otp_app: :mark_live,
    adapter: Ecto.Adapters.Postgres
end
