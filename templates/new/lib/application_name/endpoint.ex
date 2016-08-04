defmodule <%= application_module %>.Endpoint do
  use Phoenix.Endpoint, otp_app: :<%= application_name %>

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.Head

  plug <%= application_module %>.Router
end
