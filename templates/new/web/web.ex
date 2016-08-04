defmodule <%= application_module %>.Web do
  def controller do
    quote do
      use Phoenix.Controller<%= if namespaced? do %>, namespace: <%= application_module %><% end %>
      import <%= application_module %>.Router.Helpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
