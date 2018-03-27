defmodule Stopwatch.Mixfile do
  use Mix.Project

  def project do
    [
      app: :stopwatch,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      preferred_cli_env: [espec: :test],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:meta, git: "https://github.com/efcasado/meta.git", branch: "forms-0.1.0"},
      # Dev
      {:earmark, "~> 1.2",    only: :dev},
      {:ex_doc,  "~> 0.18.3", only: :dev},
      # Test
      {:espec,   "~> 1.5.0",  only: :test}
    ]
  end
end
