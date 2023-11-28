defmodule Mix.Tasks.Nodelix do
  use Mix.Task

  @moduledoc """
  Invokes `node` with the given args.

  Usage:

      $ mix nodelix TASK_OPTIONS PROFILE NODE_ARGS

  Example:

      $ mix nodelix default some-script.js --some-option

  If Node.js is not installed, it is automatically downloaded.
  The arguments given to this task will be appended
  to any configured arguments.

  ## Options

    * `--runtime-config` - load the runtime configuration
      before executing command

  Flags to control this Mix task must be given before the
  profile:

      $ mix nodelix --runtime-config default some-script.js --some-option
  """

  @shortdoc "Invokes node with the profile and args"
  @compile {:no_warn_undefined, Mix}
  @dialyzer {:no_missing_calls, run: 1}

  @impl Mix.Task
  def run(args) do
    switches = [runtime_config: :boolean]
    {opts, remaining_args} = OptionParser.parse_head!(args, switches: switches)

    if function_exported?(Mix, :ensure_application!, 1) do
      Mix.ensure_application!(:inets)
      Mix.ensure_application!(:ssl)
    end

    if opts[:runtime_config] do
      Mix.Task.run("app.config")
    else
      Mix.Task.run("loadpaths")
      Application.ensure_all_started(:nodelix)
    end

    Mix.Task.reenable("nodelix")
    install_and_run(remaining_args)
  end

  defp install_and_run([profile | args] = all) do
    case Nodelix.install_and_run(String.to_atom(profile), args) do
      0 -> :ok
      status -> Mix.raise("`mix nodelix #{Enum.join(all, " ")}` exited with #{status}")
    end
  end

  defp install_and_run([]) do
    Mix.raise("`mix nodelix` expects the profile as argument")
  end
end
