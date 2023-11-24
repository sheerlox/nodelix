defmodule Mix.Tasks.Nodelix.Install do
  use Mix.Task

  alias Nodelix.NodeDownloader

  @moduledoc """
  Installs Node.js.

      $ mix nodelix.install
      $ mix nodelix.install --if-missing

  By default, it installs #{NodeDownloader.latest_lts_version()} but you
  can configure it in your config files, such as:

      config :nodelix, :version, "#{NodeDownloader.latest_lts_version()}"

  ## Options

      * `--runtime-config` - load the runtime configuration
        before executing command

      * `--if-missing` - install only if the given version
        does not exist
  """

  @shortdoc "Installs Node.js"
  @compile {:no_warn_undefined, Mix}

  @impl true
  def run(args) do
    valid_options = [runtime_config: :boolean, if_missing: :boolean, assets: :boolean]

    {opts, base_url} =
      case OptionParser.parse_head!(args, strict: valid_options) do
        {opts, []} ->
          {opts, NodeDownloader.default_base_url()}

        {opts, [base_url]} ->
          {opts, base_url}

        {_, _} ->
          Mix.raise("""
          Invalid arguments to nodelix.install, expected one of:

              mix nodelix.install
              mix nodelix.install 'https://nodejs.org/dist/v$version/node-v$version-$target'
              mix nodelix.install --runtime-config
              mix nodelix.install --if-missing
          """)
      end

    if opts[:runtime_config], do: Mix.Task.run("app.config")

    if opts[:if_missing] && latest_lts_version?() do
      :ok
    else
      if function_exported?(Mix, :ensure_application!, 1) do
        Mix.ensure_application!(:inets)
        Mix.ensure_application!(:ssl)
      end

      Mix.Task.run("loadpaths")
      NodeDownloader.install(base_url)
    end
  end

  defp latest_lts_version?() do
    version = Nodelix.configured_version()
    match?({:ok, ^version}, NodeDownloader.bin_version())
  end
end
