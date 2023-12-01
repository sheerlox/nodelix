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

  There is one global configuration for the nodelix application:

  - `:cacerts_path` - the directory to find certificates for
      https connections

  ## Profiles

  You can define multiple nodelix profiles. There is a default empty profile
  which you can configure its args, current directory and environment:

  ```elixir
  config :nodelix,
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
      env: [
        NODE_DEBUG: "*"
      ]
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
    Supervisor.start_link([], strategy: :one_for_one)
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
  def run(version, profile, extra_args \\ []) when is_atom(profile) and is_list(extra_args) do
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

    VersionManager.bin_path(:node, version)
    |> System.cmd(args, opts)
    |> elem(1)
  end

  @doc """
  Installs Node.js if the configured version is not available,
  and then runs `node`.

  Returns the same as `run/3`.
  """
  def install_and_run(version, profile, args) do
    unless VersionManager.is_installed?(version) do
      VersionManager.install(version)
    end

    run(version, profile, args)
  end
end
