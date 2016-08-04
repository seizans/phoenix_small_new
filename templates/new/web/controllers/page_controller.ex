defmodule <%= application_module %>.PageController do
  use <%= application_module %>.Web, :controller

  def index(conn, _params) do
    conn
    |> json(%{spam: :ham})
  end
end
