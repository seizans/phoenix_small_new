defmodule <%= application_module %>.Router do
  use <%= application_module %>.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", <%= application_module %> do
    pipe_through :api

    get "/page", PageController, :index
  end
end
