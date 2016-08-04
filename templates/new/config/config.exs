use Mix.Config

config :<%= application_name %>, <%= application_module %>.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "<%= secret_key_base %>",
  render_errors: [view: <%= application_module %>.ErrorView, accepts: ~w(json)]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
<%= generator_config %>

import_config "#{Mix.env}.exs"
