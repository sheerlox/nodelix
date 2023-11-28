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

  test "run on default" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Mix.Task.run("nodelix", ["default", "--version"]) == :ok
           end) =~ @version
  end

  test "run on profile" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Mix.Task.run("nodelix", ["another", "--version"]) == :ok
           end) =~ @version
  end

  test "updates on install" do
    Application.put_env(:nodelix, :version, "20.9.0")
    Mix.Task.rerun("nodelix.install", ["--if-missing"])

    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Mix.Task.run("nodelix", ["default", "--version"]) == :ok
           end) =~ "20.9.0"

    Application.delete_env(:nodelix, :version)

    Mix.Task.rerun("nodelix.install", ["--if-missing"])

    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Mix.Task.run("nodelix", ["default", "--version"]) == :ok
           end) =~ @version
  end

  test "installs with custom URL" do
    assert :ok =
             Mix.Task.rerun("nodelix.install", [
               "https://nodejs.org/dist/v$version/node-v$version-$target.$ext"
             ])
  end
end
