defmodule Nodelix do
  use Application
  require Logger

  alias Nodelix.NodeDownloader

  @moduledoc """
  Nodelix is an installer and runner for [Node.js](https://nodejs.org/).

  ## Profiles

  You can define multiple nodelix profiles. By default, there is a
  profile called `:default` which you can configure its args, current
  directory and environment:

      config :nodelix,
        version: "#{NodeDownloader.latest_lts_version()}",
        default: [
          args: ~w(
            --version
          ),
          cd: Path.expand("../assets", __DIR__),
        ]

  ## Nodelix configuration

  There are two global configurations for the nodelix application:

    * `:version` - the expected Node.js version

    * `:cacerts_path` - the directory to find certificates for
      https connections

  """

  @doc false
  def start(_, _) do
    unless Application.get_env(:nodelix, :version) do
      Logger.warn("""
      Node.js version is not configured. Please set it in your config files:

          config :nodelix, :version, "#{NodeDownloader.latest_lts_version()}"
      """)
    end

    configured_version = configured_version()

    case NodeDownloader.bin_version() do
      {:ok, ^configured_version} ->
        :ok

      {:ok, version} ->
        Logger.warn("""
        Outdated Node.js version. Expected #{configured_version}, got #{version}. \
        Please run `mix nodelix.install` or update the version in your config files.\
        """)

      :error ->
        :ok
    end

    Supervisor.start_link([], strategy: :one_for_one)
  end

  @doc """
  Returns the configured Node.js version.
  """
  def configured_version do
    Application.get_env(:nodelix, :version, NodeDownloader.latest_lts_version())
  end

  @doc """
  Returns the configuration for the given profile.

  Returns nil if the profile does not exist.
  """
  def config_for!(profile) when is_atom(profile) do
    Application.get_env(:nodelix, profile) ||
      raise ArgumentError, """
      unknown nodelix profile. Make sure the profile is defined in your config/config.exs file, such as:

          config :nodelix,
            version: "#{NodeDownloader.latest_lts_version()}",
            #{profile}: [
              args: ~w(
                --version
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

    NodeDownloader.bin_path()
    |> System.cmd(args ++ extra_args, opts)
    |> elem(1)
  end

  defp add_env_variable_to_ignore_browserslist_outdated_warning(env) do
    Enum.into(env, %{"BROWSERSLIST_IGNORE_OLD_DATA" => "1"})
  end

  @doc """
  Installs, if not available, and then runs `node`.

  Returns the same as `run/2`.
  """
  def install_and_run(profile, args) do
    unless File.exists?(NodeDownloader.bin_path()) do
      NodeDownloader.install()
    end

    run(profile, args)
  end
end
