defmodule NodelixTest do
  use ExUnit.Case, async: true

  @version Nodelix.NodeDownloader.latest_lts_version()

  setup do
    Application.put_env(:nodelix, :version, @version)
    :ok
  end

  test "run on default" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Nodelix.run(:default, ["--version"]) == 0
           end) =~ @version
  end

  test "run on profile" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Nodelix.run(:another, []) == 0
           end) =~ @version
  end

  test "updates on install" do
    Application.put_env(:nodelix, :version, "20.9.0")
    Mix.Task.rerun("nodelix.install", ["--if-missing"])

    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Nodelix.run(:default, ["--version"]) == 0
           end) =~ "20.9.0"

    Application.delete_env(:nodelix, :version)

    Mix.Task.rerun("nodelix.install", ["--if-missing"])

    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Nodelix.run(:default, ["--version"]) == 0
           end) =~ @version
  end

  test "installs with custom URL" do
    assert :ok =
             Mix.Task.rerun("nodelix.install", [
               "https://nodejs.org/dist/v$version/node-v$version-$target"
             ])
  end
end
