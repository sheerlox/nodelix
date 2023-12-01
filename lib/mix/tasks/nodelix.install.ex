defmodule Mix.Tasks.Nodelix.Install do
  use Mix.Task

  alias Nodelix.VersionManager

  @moduledoc """
  Installs Node.js.

  > ### Warning {: .warning}
  >
  > This is a pre-release version. As such, anything _may_ change at any time, the public
  > API _should not_ be considered stable, and using a pinned version is _recommended_.

      $ mix nodelix.install
      $ mix nodelix.install --version 18.18.2
      $ mix nodelix.install --force

  ## Options

    - `--version` - name of the profile to use, defaults to latest known
    LTS version (`#{VersionManager.latest_lts_version()}`)

    - `--force` - install even if the given version is already present

    - `--runtime-config` - load the runtime configuration
      before executing command

  """

  @shortdoc "Installs Node.js"
  @compile {:no_warn_undefined, Mix}
  @dialyzer {:no_missing_calls, run: 1}

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(args) do
    valid_options = [version: :string, force: :boolean, runtime_config: :boolean]

    {opts, archive_base_url} =
      case OptionParser.parse_head!(args, strict: valid_options) do
        {opts, []} ->
          {opts, VersionManager.default_archive_base_url()}

        {opts, [archive_base_url]} ->
          {opts, archive_base_url}

        {_, _} ->
          Mix.raise("""
          Invalid arguments to nodelix.install, expected one of:

              mix nodelix.install
              mix nodelix.install 'https://nodejs.org/dist/v$version/node-v$version-$target.$ext'
              mix nodelix.install --version 18.18.2
              mix nodelix.install --force
              mix nodelix.install --runtime-config
          """)
      end

    version = opts[:version] || VersionManager.latest_lts_version()

    if opts[:runtime_config], do: Mix.Task.run("app.config")

    if VersionManager.is_installed?(version) and !opts[:force] do
      :ok
    else
      if function_exported?(Mix, :ensure_application!, 1) do
        Mix.ensure_application!(:inets)
        Mix.ensure_application!(:ssl)
      end

      Mix.Task.run("loadpaths")
      VersionManager.install(version, archive_base_url)
    end
  end
end
