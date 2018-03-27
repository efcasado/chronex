defmodule Stopwatch.Mixfile do
  use Mix.Project

  def project do
    [
      app: :stopwatch,
      version: version(),
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      preferred_cli_env: [espec: :test],
      test_coverage: [tool: ExCoveralls, test_task: "espec"],
      preferred_cli_env: [
        "coveralls": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps()
    ]
  end

  def version do
    case System.cmd("git", ["rev-list", "--tags", "--max-count=1"]) do
      {last, 0} ->
        last = String.trim(last)
        case System.cmd("git", ["describe", "--exact-match", "--tags", last]) do
          {"v" <> vsn, 0} -> String.trim(vsn)
          {_,   _} -> "0.1.0"
        end
      {_,   _} -> "0.1.0"
    end
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
      {:earmark,     "~> 1.2",    only: :dev},
      {:ex_doc,      "~> 0.18.3", only: :dev},
      # Test
      {:espec,       "~> 1.5.0",  only: :test},
      {:excoveralls, "~> 0.8.1",  only: :test}
    ]
  end
end
