defmodule EctoFlex.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :ecto_flex,
    adapter: Ecto.Adapters.Postgres,
    pool: Ecto.Adapters.SQL.Sandbox
end
