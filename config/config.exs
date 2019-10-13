use Mix.Config

config :ecto_flex, ecto_repos: [EctoFlex.Repo]

import_config "#{Mix.env()}.exs"
