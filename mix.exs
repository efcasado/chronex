defmodule Chronex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :chronex,
      version: "1.0.3",
      description: "Library to seamlessly add instrumentation to your code.",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      preferred_cli_env: [
        coveralls: :test,
        espec:     :test
      ],
      test_coverage: [tool: ExCoveralls, test_task: "espec"],
      preferred_cli_env: [
        "coveralls":        :test,
        "coveralls.detail": :test,
        "coveralls.post":   :test,
        "coveralls.html":   :test
      ],
      elixirc_options: [debug_info: true],
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      env: [
        backends: [Chronex.Backends.Logger]
      ]
    ]
  end

  defp deps do
    [
      {:meta,        "~> 0.1.3"},
      {:uuid,        "~> 1.1"},
      # Dev
      {:earmark,     "~> 1.2",    only: :dev},
      {:ex_doc,      "~> 0.18.3", only: :dev},
      # Test
      {:espec,       "~> 1.5.0",  only: :test},
      {:excoveralls, "~> 0.8.1",  only: :test}
    ]
  end

  defp package do
    %{
      maintainers: ["Enrique Fernandez"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/efcasado/chronex"}
    }
  end
end
