defmodule Nodelix do
  use Application
  require Logger

  alias Nodelix.NodeManager

  @moduledoc """
  Nodelix is an installer and runner for [tailwind](https://tailwindcss.com/).

  ## Profiles

  You can define multiple tailwind profiles. By default, there is a
  profile called `:default` which you can configure its args, current
  directory and environment:

      config :nodelix,
        version: "#{NodeManager.latest_version()}",
        default: [
          args: ~w(
            --config=tailwind.config.js
            --input=css/app.css
            --output=../priv/static/assets/app.css
          ),
          cd: Path.expand("../assets", __DIR__),
        ]

  ## Nodelix configuration

  There are two global configurations for the tailwind application:

    * `:version` - the expected tailwind version

    * `:cacerts_path` - the directory to find certificates for
      https connections

    * `:path` - the path to find the tailwind executable at. By
      default, it is automatically downloaded and placed inside
      the `_build` directory of your current app

  Overriding the `:path` is not recommended, as we will automatically
  download and manage `tailwind` for you. But in case you can't download
  it (for example, GitHub behind a proxy), you may want to
  set the `:path` to a configurable system location.

  For instance, you can install `tailwind` globally with `npm`:

      $ npm install -g tailwindcss

  On Unix, the executable will be at:

      NPM_ROOT/tailwind/node_modules/tailwind-TARGET/bin/tailwind

  On Windows, it will be at:

      NPM_ROOT/tailwind/node_modules/tailwind-windows-(32|64)/tailwind.exe

  Where `NPM_ROOT` is the result of `npm root -g` and `TARGET` is your system
  target architecture.

  Once you find the location of the executable, you can store it in a
  `MIX_TAILWIND_PATH` environment variable, which you can then read in
  your configuration file:

      config :nodelix, path: System.get_env("MIX_TAILWIND_PATH")

  """

  @doc false
  def start(_, _) do
    unless Application.get_env(:nodelix, :version) do
      Logger.warn("""
      tailwind version is not configured. Please set it in your config files:

          config :nodelix, :version, "#{NodeManager.latest_version()}"
      """)
    end

    configured_version = configured_version()

    case NodeManager.bin_version() do
      {:ok, ^configured_version} ->
        :ok

      {:ok, version} ->
        Logger.warn("""
        Outdated tailwind version. Expected #{configured_version}, got #{version}. \
        Please run `mix nodelix.install` or update the version in your config files.\
        """)

      :error ->
        :ok
    end

    Supervisor.start_link([], strategy: :one_for_one)
  end

  @doc """
  Returns the configured tailwind version.
  """
  def configured_version do
    Application.get_env(:nodelix, :version, NodeManager.latest_version())
  end

  @doc """
  Returns the configuration for the given profile.

  Returns nil if the profile does not exist.
  """
  def config_for!(profile) when is_atom(profile) do
    Application.get_env(:nodelix, profile) ||
      raise ArgumentError, """
      unknown tailwind profile. Make sure the profile is defined in your config/config.exs file, such as:

          config :nodelix,
            version: "#{NodeManager.latest_version()}",
            #{profile}: [
              args: ~w(
                --config=tailwind.config.js
                --input=css/app.css
                --output=../priv/static/assets/app.css
              ),
              cd: Path.expand("../assets", __DIR__)
            ]
      """
  end

  @doc """
  Runs the given command with `args`.

  The given args will be appended to the configured args.
  The task output will be streamed directly to stdio. It
  returns the status of the underlying call.
  """
  def run(profile, extra_args) when is_atom(profile) and is_list(extra_args) do
    config = config_for!(profile)
    args = config[:args] || []

    env =
      config
      |> Keyword.get(:env, %{})
      |> add_env_variable_to_ignore_browserslist_outdated_warning()

    opts = [
      cd: config[:cd] || File.cwd!(),
      env: env,
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true
    ]

    NodeManager.bin_path()
    |> System.cmd(args ++ extra_args, opts)
    |> elem(1)
  end

  defp add_env_variable_to_ignore_browserslist_outdated_warning(env) do
    Enum.into(env, %{"BROWSERSLIST_IGNORE_OLD_DATA" => "1"})
  end

  @doc """
  Installs, if not available, and then runs `tailwind`.

  Returns the same as `run/2`.
  """
  def install_and_run(profile, args) do
    unless File.exists?(NodeManager.bin_path()) do
      NodeManager.install()
    end

    run(profile, args)
  end
end
