defmodule <%= application_module %>.Mixfile do
  use Mix.Project

  def project do
    [app: :<%= application_name %>,
     version: "0.0.1",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [mod: {<%= application_module %>, []},
     applications: [:phoenix, :phoenix_pubsub, :cowboy, :logger]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp deps do
    [<%= phoenix_dep %>,
     {:phoenix_pubsub, "~> 1.0"},
     {:cowboy, "~> 1.0"}]
  end
end
