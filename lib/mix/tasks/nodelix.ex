defmodule Mix.Tasks.Nodelix do
  use Mix.Task

  alias Nodelix.VersionManager

  @moduledoc """
  Invokes `node` with the provided arguments.

  > ### Warning {: .warning}
  >
  > This is a pre-release version. As such, anything _may_ change at any time, the public
  > API _should not_ be considered stable, and using a pinned version is _recommended_.

  Usage:

      $ mix nodelix TASK_OPTIONS NODE_ARGS

  Example:

      $ mix nodelix some-script.js --some-option

  Refer to `Nodelix` for more information on configuration and profiles.

  ## Options

    - `--version` - Node.js version to use, defaults to latest known
    LTS version (`#{VersionManager.latest_lts_version()}`)

    - `--profile` - name of the profile to use, defaults to `default`

    - `--runtime-config` - load the runtime configuration
      before executing command

  Flags to control this Mix task must be given before the
  node arguments:

      $ mix nodelix --version 18.18.2 --profile default --runtime-config some-script.js --some-option

  """

  @shortdoc "Invokes node with the provided arguments"
  @compile {:no_warn_undefined, Mix}
  @dialyzer {:no_missing_calls, run: 1}

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(args) do
    switches = [version: :string, profile: :string, runtime_config: :boolean]

    {opts, remaining_args, invalid_opts} = OptionParser.parse_head(args, strict: switches)
    node_args = Enum.map(invalid_opts, &elem(&1, 0)) ++ remaining_args

    if function_exported?(Mix, :ensure_application!, 1) do
      Mix.ensure_application!(:inets)
      Mix.ensure_application!(:ssl)
    end

    version = opts[:version] || VersionManager.latest_lts_version()

    profile = opts[:profile] || "default"

    if opts[:runtime_config] do
      Mix.Task.run("app.config")
    else
      Mix.Task.run("loadpaths")
      Application.ensure_all_started(:nodelix)
    end

    Mix.Task.reenable("nodelix")
    install_and_run(version, profile, node_args)
  end

  defp install_and_run(version, profile, args) do
    case Nodelix.install_and_run(version, String.to_atom(profile), args) do
      0 ->
        :ok

      status ->
        Mix.raise(
          "`mix nodelix --version #{version} --profile #{profile} #{Enum.join(args, " ")}` exited with #{status}"
        )
    end
  end
end
