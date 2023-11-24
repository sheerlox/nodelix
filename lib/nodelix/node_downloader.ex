defmodule Nodelix.NodeDownloader do
  # https://nodejs.org/en/about/previous-releases
  @latest_lts_version "20.10.0"

  @default_archive_url "https://nodejs.org/dist/v$version/node-v$version-$target"
  @checksums_url "https://nodejs.org/dist/v$version/SHASUMS256.txt"
  @checksums_signature_url "https://nodejs.org/dist/v$version/SHASUMS256.txt.sig"

  require Logger

  alias Nodelix.HttpUtils

  @moduledoc false

  @doc """
  TODO
  - [X] fetch Node.js archive for a version and platform (https://nodejs.org/dist/v20.10.0/)
  - [X] fetch checksums file (https://nodejs.org/dist/v20.10.0/SHASUMS256.txt)
  - [X] fetch checksums file signature (https://nodejs.org/dist/v20.10.0/SHASUMS256.txt.sig)
  - [ ] fetch Node.js signing keys list (https://raw.githubusercontent.com/nodejs/release-keys/main/keys.list)
  - [ ] fetch keys (https://raw.githubusercontent.com/nodejs/release-keys/main/keys/4ED778F539E3634C779C87C6D7062848A1AB005C.asc)
  - [ ] convert keys to PEM (https://stackoverflow.com/questions/10966256/erlang-importing-gpg-public-key)
  - [ ] check signature of the checksums file with each key until there's a match
  - [ ] match the hash for the archive filename
  - [ ] check integrity of the downloaded archive
  - [ ] decompress archive (delete destination first, see https://github.com/phoenixframework/tailwind/pull/67)
  """
  def todo, do: []

  @doc """
  Returns the latest known LTS version at the time of publishing.
  """
  def latest_lts_version, do: @latest_lts_version

  @doc """
  The default URL to fetch the Node.js archive from.
  """
  def default_archive_url, do: @default_archive_url

  @doc """
  Returns the path to the node executable.

  The executable may not be available if it was not yet installed.
  """
  def bin_path, do: Map.get(paths(), :node)

  @doc """
  Returns the version of the tailwind executable.

  Returns `{:ok, version_string}` on success or `:error` when the executable
  is not available.
  """
  def bin_version do
    path = bin_path()

    with true <- File.exists?(path),
         {out, 0} <- System.cmd(path, ["--help"]),
         [vsn] <- Regex.run(~r/tailwindcss v([^\s]+)/, out, capture: :all_but_first) do
      {:ok, vsn}
    else
      _ -> :error
    end
  end

  @doc """
  Installs Node.js with `configured_version/0`.
  """
  def install(archive_url \\ @default_archive_url) do
    fetch_archive(archive_url)
    fetch_checksums_and_signature()
  end

  defp fetch_archive(archive_url) do
    url = get_url(archive_url)
    %{archive: archive_path} = paths()

    Logger.debug("Downloading Node.js from #{url}")
    binary = HttpUtils.fetch_body!(url)
    File.write!(archive_path, binary, [:binary])
  end

  defp fetch_checksums_and_signature() do
    checksums_url = get_url(@checksums_url)
    checksums_signature_url = get_url(@checksums_signature_url)

    %{checksums: checksums_path, signature: signature_path} = paths()

    Logger.debug("Downloading checksums from #{checksums_url}")
    binary = HttpUtils.fetch_body!(checksums_url)
    File.write!(checksums_path, binary, [:binary])

    Logger.debug("Downloading signature from #{checksums_signature_url}")
    binary = HttpUtils.fetch_body!(checksums_signature_url)
    File.write!(signature_path, binary, [:binary])
  end

  defp paths do
    name = "node-#{Nodelix.configured_version()}"

    base_path =
      if Code.ensure_loaded?(Mix.Project) do
        Path.dirname(Mix.Project.build_path())
      else
        Path.expand("_build")
      end

    File.mkdir_p!(base_path)

    %{
      :archive => Path.join(base_path, "#{name}-#{target()}"),
      :checksums => Path.join(base_path, "SHASUMS256-#{name}.txt"),
      :signature => Path.join(base_path, "SHASUMS256-#{name}.txt.sig"),
      :node => Path.join(base_path, "#{name}/bin/node")
    }
  end

  # Available targets:
  # aix-ppc64.tar.gz
  # darwin-arm64.tar.gz
  # darwin-x64.tar.gz
  # linux-arm64.tar.gz
  # linux-armv7l.tar.gz
  # linux-ppc64le.tar.gz
  # linux-s390x.tar.gz
  # linux-x64.tar.gz
  # win-arm64.zip
  # win-x64.zip
  # win-x86.zip
  defp target do
    arch_str = :erlang.system_info(:system_architecture)
    [arch | _] = arch_str |> List.to_string() |> String.split("-")

    case {:os.type(), arch, :erlang.system_info(:wordsize) * 8} do
      {{:unix, :aix}, "ppc64", 64} -> "aix-ppc64.tar.gz"
      {{:unix, :darwin}, arch, 64} when arch in ~w(arm aarch64) -> "darwin-arm64.tar.gz"
      {{:unix, :darwin}, "x86_64", 64} -> "darwin-x64.tar.gz"
      {{:unix, :linux}, "aarch64", 64} -> "linux-arm64.tar.gz"
      {{:unix, :linux}, "armv7l", 32} -> "linux-armv7l.tar.gz"
      {{:unix, :linux}, "ppc64le", 64} -> "linux-ppc64le.tar.gz"
      {{:unix, :linux}, "s390x", 32} -> "linux-s390x.tar.gz"
      {{:unix, _osname}, arch, 64} when arch in ~w(x86_64 amd64) -> "linux-x64.tar.gz"
      {{:win32, _}, "aarch64", 64} -> "win-arm64.zip"
      {{:win32, _}, _arch, 64} -> "win-x64.zip"
      {{:win32, _}, _arch, 32} -> "win-x86.zip"
      {_os, _arch, _wordsize} -> raise "Node.js is not available for architecture: #{arch_str}"
    end
  end

  defp get_url(base_url) do
    base_url
    |> String.replace("$version", Nodelix.configured_version())
    |> String.replace("$target", target())
  end
end
