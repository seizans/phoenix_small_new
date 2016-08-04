defmodule <%= application_module %>.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", <%= application_module %> do
    pipe_through :api

    get "/page", PageController, :index
  end
end
