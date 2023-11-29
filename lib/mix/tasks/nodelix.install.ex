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
      $ mix nodelix.install --if-missing

  By default, it installs #{VersionManager.latest_lts_version()} but you
  can configure it in your config files, such as:

      config :nodelix, :version, "#{VersionManager.latest_lts_version()}"

  ## Options

    - `--runtime-config` - load the runtime configuration
      before executing command

    - `--if-missing` - install only if the given version
      does not exist
  """

  @shortdoc "Installs Node.js"
  @compile {:no_warn_undefined, Mix}
  @dialyzer {:no_missing_calls, run: 1}

  @impl Mix.Task
  def run(args) do
    valid_options = [runtime_config: :boolean, if_missing: :boolean, assets: :boolean]

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
              mix nodelix.install --runtime-config
              mix nodelix.install --if-missing
          """)
      end

    if opts[:runtime_config], do: Mix.Task.run("app.config")

    configured_version = Nodelix.configured_version()

    if opts[:if_missing] && VersionManager.is_installed?(configured_version) do
      :ok
    else
      if function_exported?(Mix, :ensure_application!, 1) do
        Mix.ensure_application!(:inets)
        Mix.ensure_application!(:ssl)
      end

      Mix.Task.run("loadpaths")
      VersionManager.install(configured_version, archive_base_url)
    end
  end
end
