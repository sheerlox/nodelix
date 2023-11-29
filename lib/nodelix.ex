defmodule Nodelix do
  use Application
  require Logger

  alias Nodelix.VersionManager

  @moduledoc """
  Nodelix is an installer and runner for [Node.js](https://nodejs.org/).

  > ### Warning {: .warning}
  >
  > This is a pre-release version. As such, anything _may_ change at any time, the public
  > API _should not_ be considered stable, and using a pinned version is _recommended_.

  ## Nodelix configuration

  There are two global configurations for the nodelix application:

  - `:version` - the Node.js version to use

  - `:cacerts_path` - the directory to find certificates for
      https connections

  ## Profiles

  You can define multiple nodelix profiles. There is a default empty profile
  which you can configure its args, current directory and environment:

  ```elixir
  config :nodelix,
  version: "#{VersionManager.latest_lts_version()}",
  default: [
    args: ~w(
      some-script.js
      --some-option
    ),
    cd: Path.expand("../assets", __DIR__),
  ],
  custom: [
    args: ~w(
      another-script.js
      --another-option
    ),
    cd: Path.expand("../assets/scripts", __DIR__),
  ]
  ```

  The default current directory is your project's root.

  To use a profile other than `default`, you can use
  the `--profile` option:

  ```shell
  mix nodelix --profile custom
  ```

  When `mix nodelix` is invoked, the task arguments will
  be appended to the ones configured in the profile.

  """

  @doc false
  def start(_, _) do
    unless Application.get_env(:nodelix, :version) do
      latest_lts_version = VersionManager.latest_lts_version()

      Logger.warning("""
      Node.js version is not configured. Please set it in your config files:

          config :nodelix, :version, "#{latest_lts_version}"

      Using latest known LTS version at the time of release: #{latest_lts_version}
      """)
    end

    Supervisor.start_link([], strategy: :one_for_one)
  end

  @doc """
  Returns the configured Node.js version.
  """
  def configured_version do
    Application.get_env(:nodelix, :version, VersionManager.latest_lts_version())
  end

  @doc """
  Returns the configuration for the given profile.

  Raises if the profile does not exist.
  """
  def config_for!(profile) when is_atom(profile) do
    Application.get_env(:nodelix, profile) ||
      raise ArgumentError, """
      Unknown nodelix profile. Make sure the profile is defined in your config/config.exs file, such as:

          config :nodelix,
            version: "#{VersionManager.latest_lts_version()}",
            #{profile}: [
              args: ~w(
                some-script.js
                --some-option
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
  def run(profile, extra_args \\ []) when is_atom(profile) and is_list(extra_args) do
    config = config_for!(profile)
    args = (config[:args] || []) ++ extra_args

    if length(args) == 0, do: raise(ArgumentError, "No argument provided.")

    env = Keyword.get(config, :env, %{})

    opts = [
      cd: config[:cd] || File.cwd!(),
      env: env,
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true
    ]

    VersionManager.bin_path(:node, Nodelix.configured_version())
    |> System.cmd(args, opts)
    |> elem(1)
  end

  @doc """
  Installs Node.js if the configured version is not available,
  and then runs `node`.

  Returns the same as `run/2`.
  """
  def install_and_run(profile, args) do
    version = configured_version()

    unless VersionManager.is_installed?(version) do
      VersionManager.install(version)
    end

    run(profile, args)
  end
end
