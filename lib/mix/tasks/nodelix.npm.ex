defmodule Mix.Tasks.Nodelix.Npm do
  use Mix.Task

  @moduledoc """
  Invokes `npm` with the provided arguments.

  > ### Warning {: .warning}
  >
  > This is a pre-release version. As such, anything _may_ change at any time, the public
  > API _should not_ be considered stable, and using a pinned version is _recommended_.

  Usage:

      $ mix nodelix.npm TASK_OPTIONS NODE_ARGS

  Example:

      $ mix nodelix.npm install --save-dev semantic-release semantic-release-hex

  Refer to `Mix.Tasks.Nodelix` for task options and to `Nodelix` for more information
  on configuration and profiles.

  """

  alias Nodelix.VersionManager

  @shortdoc "Invokes npm with the provided arguments"
  @dialyzer {:no_missing_calls, run: 1}

  @impl Mix.Task
  def run(args) do
    npm_path = VersionManager.bin_path(:npm, Nodelix.configured_version())

    Mix.Task.run("nodelix", [npm_path | args])
  end
end
