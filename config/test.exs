use Mix.Config

config :ecto_flex, EctoFlex.Repo,
  username: "ecto_flex",
  password: "ecto_flex",
  database: "ecto_flex_test_db",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
