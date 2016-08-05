defmodule Mix.Tasks.Phoenix.SmallNew do
  use Mix.Task
  import Mix.Generator

  @phoenix Path.expand("../..", __DIR__)
  @version Mix.Project.config[:version]
  @shortdoc "Creates a small new Phoenix v#{@version} application"

  # File mappings

  @new [
    {:eex,  "new/config/config.exs",                         "config/config.exs"},
    {:eex,  "new/config/dev.exs",                            "config/dev.exs"},
    {:eex,  "new/config/prod.exs",                           "config/prod.exs"},
    {:eex,  "new/config/prod.secret.exs",                    "config/prod.secret.exs"},
    {:eex,  "new/config/test.exs",                           "config/test.exs"},
    {:eex,  "new/lib/application_name.ex",                   "lib/application_name.ex"},
    {:eex,  "new/lib/application_name/endpoint.ex",          "lib/application_name/endpoint.ex"},
    {:keep, "new/test/controllers",                          "test/controllers"},
    {:eex,  "new/test/support/conn_case.ex",                 "test/support/conn_case.ex"},
    {:eex,  "new/test/test_helper.exs",                      "test/test_helper.exs"},
    {:keep, "new/web/controllers",                           "web/controllers"},
    {:eex,  "new/web/controllers/page_controller.ex",        "web/controllers/page_controller.ex"},
    {:eex,  "new/web/router.ex",                             "web/router.ex"},
    {:eex,  "new/mix.exs",                                   "mix.exs"},
    {:eex,  "new/README.md",                                 "README.md"},
  ]

  # Embed all defined templates
  root = Path.expand("../templates", __DIR__)

  for {format, source, _} <- @new do
    unless format == :keep do
      @external_resource Path.join(root, source)
      def render(unquote(source)), do: unquote(File.read!(Path.join(root, source)))
    end
  end

  @switches [dev: :boolean,
             app: :string, module: :string,
             binary_id: :boolean]

  def run([version]) when version in ~w(-v --version) do
    Mix.shell.info "Phoenix v#{@version}"
  end

  def run(argv) do
    unless Version.match? System.version, "~> 1.2" do
      Mix.raise "Phoenix v#{@version} requires at least Elixir v1.2.\n " <>
                "You have #{System.version}. Please update accordingly"
    end

    {opts, argv} =
      case OptionParser.parse(argv, strict: @switches) do
        {opts, argv, []} ->
          {opts, argv}
        {_opts, _argv, [switch | _]} ->
          Mix.raise "Invalid option: " <> switch_to_string(switch)
      end

    case argv do
      [] ->
        Mix.Task.run "help", ["phoenix.small_new"]
      [path|_] ->
        app = opts[:app] || Path.basename(Path.expand(path))
        check_application_name!(app, !!opts[:app])
        check_directory_existence!(app)
        mod = opts[:module] || Macro.camelize(app)
        check_module_name_validity!(mod)
        check_module_name_availability!(mod)

        run(app, mod, path, opts)
    end
  end

  def run(app, mod, path, opts) do
    phoenix_path = phoenix_path(path, Keyword.get(opts, :dev, false))

    in_umbrella? = in_umbrella?(path)

    binding = [application_name: app,
               application_module: mod,
               phoenix_dep: phoenix_dep(phoenix_path),
               phoenix_path: phoenix_path,
               secret_key_base: random_string(64),
               prod_secret_key_base: random_string(64),
               signing_salt: random_string(8),
               in_umbrella: in_umbrella?,
               hex?: Code.ensure_loaded?(Hex),
               namespaced?: Macro.camelize(app) != mod]

    copy_from path, binding, @new

    # Parallel installs
    install? = Mix.shell.yes?("\nFetch and install dependencies?")

    File.cd!(path, fn ->
      mix?    = install_mix(install?)
      extra   = if mix?, do: [], else: ["$ mix deps.get"]

      print_mix_info(path, extra)
    end)
  end

  defp switch_to_string({name, nil}), do: name
  defp switch_to_string({name, val}), do: name <> "=" <> val

  defp install_mix(install?) do
    maybe_cmd "mix deps.get", true, install? && Code.ensure_loaded?(Hex)
  end

  defp print_mix_info(path, extra) do
    steps = ["$ cd #{path}"] ++ extra ++ ["$ mix phoenix.server"]

    Mix.shell.info """

    We are all set! Run your Phoenix application:

        #{Enum.join(steps, "\n    ")}

    You can also run your app inside IEx (Interactive Elixir) as:

        $ iex -S mix phoenix.server
    """
  end

  ## Helpers

  defp maybe_cmd(cmd, should_run?, can_run?) do
    cond do
      should_run? && can_run? ->
        cmd(cmd)
        true
      should_run? ->
        false
      true ->
        true
    end
  end

  defp cmd(cmd) do
    Mix.shell.info [:green, "* running ", :reset, cmd]
    case Mix.shell.cmd(cmd, [quiet: true]) do
      0 ->
        true
      _ ->
        Mix.shell.error [:red, "* error ", :reset, "command failed to execute, " <>
          "please run the following command again after installation: \"#{cmd}\""]
        false
    end
  end

  defp check_application_name!(name, from_app_flag) do
    unless name =~ ~r/^[a-z][\w_]*$/ do
      extra =
        if !from_app_flag do
          ". The application name is inferred from the path, if you'd like to " <>
          "explicitly name the application then use the `--app APP` option."
        else
          ""
        end

      Mix.raise "Application name must start with a letter and have only lowercase " <>
                "letters, numbers and underscore, got: #{inspect name}" <> extra
    end
  end

  defp check_module_name_validity!(name) do
    unless name =~ ~r/^[A-Z]\w*(\.[A-Z]\w*)*$/ do
      Mix.raise "Module name must be a valid Elixir alias (for example: Foo.Bar), got: #{inspect name}"
    end
  end

  defp check_module_name_availability!(name) do
    name = Module.concat(Elixir, name)
    if Code.ensure_loaded?(name) do
      Mix.raise "Module name #{inspect name} is already taken, please choose another name"
    end
  end

  def check_directory_existence!(name) do
    if File.dir?(name) && !Mix.shell.yes?("The directory #{name} already exists. Are you sure you want to continue?") do
      Mix.raise "Please select another directory for installation."
    end
  end

  defp in_umbrella?(app_path) do
    try do
      umbrella = Path.expand(Path.join [app_path, "..", ".."])
      File.exists?(Path.join(umbrella, "mix.exs")) &&
        Mix.Project.in_project(:umbrella_check, umbrella, fn _ ->
          path = Mix.Project.config[:apps_path]
          path && Path.expand(path) == Path.join(umbrella, "apps")
        end)
    catch
      _, _ -> false
    end
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end

  defp phoenix_dep("deps/phoenix"), do: ~s[{:phoenix, "~> 1.2.0"}]
  # defp phoenix_dep("deps/phoenix"), do: ~s[{:phoenix, github: "phoenixframework/phoenix", override: true}]
  defp phoenix_dep(path), do: ~s[{:phoenix, path: #{inspect path}, override: true}]

  defp phoenix_path(path, true) do
    absolute = Path.expand(path)
    relative = Path.relative_to(absolute, @phoenix)

    if absolute == relative do
      Mix.raise "--dev projects must be generated inside Phoenix directory"
    end

    relative
    |> Path.split
    |> Enum.map(fn _ -> ".." end)
    |> Path.join
  end

  defp phoenix_path(_path, false) do
    "deps/phoenix"
  end

  ## Template helpers

  defp copy_from(target_dir, binding, mapping) when is_list(mapping) do
    application_name = Keyword.fetch!(binding, :application_name)
    for {format, source, target_path} <- mapping do
      target = Path.join(target_dir,
                         String.replace(target_path, "application_name", application_name))

      case format do
        :keep ->
          File.mkdir_p!(target)
        :text ->
          create_file(target, render(source))
        :append ->
          append_to(Path.dirname(target), Path.basename(target), render(source))
        :eex  ->
          contents = EEx.eval_string(render(source), binding, file: source)
          create_file(target, contents)
      end
    end
  end

  defp append_to(path, file, contents) do
    file = Path.join(path, file)
    File.write!(file, File.read!(file) <> contents)
  end
end
