use Mix.Config

config :<%= application_name %>, <%= application_module %>.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: "example.com", port: 80]

config :logger, level: :info


# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :<%= application_name %>, <%= application_module %>.Endpoint, server: true
#

import_config "prod.secret.exs"
