defmodule EctoFlex.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_flex,
      version: "0.4.1",
      description: description(),
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "EctoFlex",
      package: package()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger] ++ applications(Mix.env())
    ]
  end

  defp applications(:test), do: [:postgrex, :ecto_sql]
  defp applications(_), do: []

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "> 0.0.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "A quick way to query your schemas."
  end

  defp package() do
    [
      maintainers: ["Abdullah Esmail"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/aesmail/ecto_flex"}
    ]
  end
end
