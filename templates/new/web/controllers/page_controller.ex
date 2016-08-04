defmodule <%= application_module %>.PageController do
  use Phoenix.Controller<%= if namespaced? do %>, namespace: <%= application_module %><% end %>
  import <%= application_module %>.Router.Helpers

  def index(conn, _params) do
    conn
    |> json(%{spam: :ham})
  end
end
