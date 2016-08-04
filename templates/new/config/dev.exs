use Mix.Config

config :<%= application_name %>, <%= application_module %>.Endpoint,
  http: [port: 4000],
  debug_errors: false,
  code_reloader: true,
  check_origin: false,
  watchers: []


config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
