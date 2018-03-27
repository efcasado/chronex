use Mix.Config

config :chronex, backends: [
  Chronex.Backends.Logger
]

config :chronex, Chronex.Backends.Logger,
  log_level: :debug

# import_config "#{Mix.env}.exs"
