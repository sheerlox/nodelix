defmodule Mix.Tasks.Nodelix.Npm do
  use Mix.Task

  alias Nodelix.VersionManager

  @moduledoc """
  Invokes `npm` with the provided arguments.

  > ### Warning {: .warning}
  >
  > This is a pre-release version. As such, anything _may_ change at any time, the public
  > API _should not_ be considered stable, and using a pinned version is _recommended_.

  Usage:

      $ mix nodelix.npm TASK_OPTIONS NODE_ARGS

  Example:

      $ mix nodelix.npm install --save-dev tailwindcss esbuild

  Refer to `Mix.Tasks.Nodelix` for task options and to `Nodelix` for more information
  on configuration and profiles.

  ## Options

    - `--version` - Node.js version to use, defaults to latest known
    LTS version (`#{VersionManager.latest_lts_version()}`)

  Flags to control this Mix task must be given before the
  node arguments:

      $ mix nodelix.npm --version 18.18.2 install --save-dev tailwindcss esbuild

  """

  @shortdoc "Invokes npm with the provided arguments"

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(args) do
    switches = [version: :string]

    {opts, remaining_args, invalid_opts} = OptionParser.parse_head(args, strict: switches)
    npm_args = Enum.map(invalid_opts, &elem(&1, 0)) ++ remaining_args

    version = opts[:version] || VersionManager.latest_lts_version()

    npm_path = VersionManager.bin_path(:npm, version)

    Mix.Tasks.Nodelix.run(["--version", version] ++ [npm_path | npm_args])
  end
end
