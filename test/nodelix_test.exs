defmodule NodelixTest do
  use ExUnit.Case, async: true

  @version Nodelix.VersionManager.latest_lts_version()

  setup_all do
    File.rm_rf!(Path.join([Mix.Project.build_path(), "nodejs"]))
    Mix.Task.run("nodelix.install")
  end

  setup do
    Application.put_env(:nodelix, :version, @version)
    :ok
  end

  test "run without profile" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Mix.Task.rerun("nodelix", ["--version"]) == :ok
           end) =~ @version
  end

  test "run on another profile" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Mix.Task.rerun("nodelix", ["--profile", "test_profile"]) == :ok
           end) =~ @version
  end

  test "installs and runs multiple versions" do
    Application.put_env(:nodelix, :version, "18.18.2")
    Mix.Task.rerun("nodelix.install")

    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Mix.Task.rerun("nodelix", ["--version"]) == :ok
           end) =~ "18.18.2"

    Application.put_env(:nodelix, :version, @version)

    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Mix.Task.rerun("nodelix", ["--version"]) == :ok
           end) =~ @version
  end

  test "re-installs with force flag" do
    assert ExUnit.CaptureLog.capture_log(fn ->
             assert Mix.Task.rerun("nodelix.install", ["--force"]) == :ok
           end) =~ "Succesfully installed Node.js v#{@version}"
  end

  test "installs with custom URL" do
    assert :ok =
             Mix.Task.rerun("nodelix.install", [
               "https://nodejs.org/dist/v$version/node-v$version-$target.$ext"
             ])
  end
end
