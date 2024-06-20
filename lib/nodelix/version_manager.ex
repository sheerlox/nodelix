defmodule Nodelix.VersionManager do
  # https://nodejs.org/en/about/previous-releases
  @latest_lts_version "20.12.2"

  @default_archive_base_url "https://nodejs.org/dist/v$version/node-v$version-$target.$ext"
  @signed_checksums_base_url "https://nodejs.org/dist/v$version/SHASUMS256.txt.asc"

  @signing_keys_list_url "https://raw.githubusercontent.com/nodejs/release-keys/main/keys.list"

  require Logger

  alias Nodelix.HttpUtils

  @moduledoc false

  @doc """
  Returns the latest known LTS version at the time of publishing.
  """
  @spec latest_lts_version() :: String.t()
  def latest_lts_version, do: @latest_lts_version

  @doc """
  The default URL to fetch the Node.js archive from.
  """
  @spec default_archive_base_url() :: String.t()
  def default_archive_base_url, do: @default_archive_base_url

  @doc """
  Returns the path to the requested executable.

  The executable may not be available if it was not yet installed.
  """
  @spec bin_path(:node | :npm, String.t()) :: String.t()
  def bin_path(:node, version) when is_binary(version), do: bin_path_p("node", version)
  def bin_path(:npm, version) when is_binary(version), do: bin_path_p("npm", version)

  defp bin_path_p(program, version),
    do: Path.join([Map.get(paths(version), :bin_dir), program])

  @doc """
  Checks if the specified Node.js version is installed.
  """
  @spec is_installed?(String.t()) :: boolean()
  def is_installed?(version) do
    node = bin_path(:node, version)

    with true <- File.exists?(node),
         {out, 0} <- System.cmd(node, ["--version"]),
         [^version] <- Regex.run(~r/v([^\s]+)/, out, capture: :all_but_first) do
      true
    else
      _ -> false
    end
  end

  @doc """
  Installs the specified Node.js version.
  """
  @spec install(String.t(), String.t()) :: :ok
  def install(version, archive_base_url \\ @default_archive_base_url)
      when is_binary(version) and is_binary(archive_base_url) do
    %{nodelix: base_path} = paths(version)

    File.mkdir_p!(base_path)

    fetch_archive(version, archive_base_url)
    fetch_checksums(version)
    verify_archive!(version)
    unpack_archive(version)

    Logger.debug(
      "Succesfully installed Node.js v#{version} in #{Map.get(paths(version), :destination)}"
    )

    :ok
  end

  defp unpack_archive(version) do
    %{archive: archive_path, destination: destination, bin_dir: bin_path} = paths(version)

    # MacOS doesn't recompute code signing information if a binary
    # is overwritten with a new version, so we force creation of a new file
    # https://github.com/phoenixframework/tailwind/issues/39
    if File.exists?(destination), do: File.rm_rf!(destination)

    # because of what seems to be a bug in `erl_tar`, we need to extract the archive
    # in memory, write each file to the disk and then manually create the npm
    # symlink (because it's causing an error if we try to write to disk directly,
    # but is simply removed when extracting in memory): https://github.com/erlang/otp/issues/5765
    # and restore file permissions (+x on `bin/*`)

    archive = File.read!(archive_path)

    content =
      case :erl_tar.extract({:binary, archive}, [:memory, :compressed]) do
        {:ok, content} -> content
        other -> raise "couldn't unpack archive: #{inspect(other)}"
      end

    Enum.each(
      content,
      fn {path, content} ->
        full_path = Path.join(destination, remove_leading_dir(path))
        File.mkdir_p!(Path.dirname(full_path))
        File.write!(full_path, content)
      end
    )

    File.ln_s!(
      Path.join([destination, "lib", "node_modules", "npm", "bin", "npm-cli.js"]),
      Path.join(bin_path, "npm")
    )

    Enum.map(File.ls!(bin_path), &File.chmod!(Path.join(bin_path, &1), 0o755))

    File.rm!(archive_path)
  end

  defp remove_leading_dir(path) do
    [_ | rest] = Path.split(path)
    Path.join(rest)
  end

  # - verifies checksums file signature
  # - extracts the corresponding archive checksum
  # - verifies archive checksum matches
  defp verify_archive!(version) do
    %{archive: archive_path, checksums: checksums_path, keystore: keystore_path} = paths(version)

    Logger.debug("Downloading signing keys list from #{@signing_keys_list_url}")

    signing_key_ids =
      @signing_keys_list_url
      |> HttpUtils.fetch_body!()
      |> String.trim()
      |> String.split("\n")

    keystore = GPGex.Keystore.get_keystore(path: keystore_path)

    missing_keys =
      signing_key_ids
      |> Enum.filter(fn key_id -> !GPGex.cmd?(["--list-keys", key_id], keystore: keystore) end)

    if length(missing_keys) > 0 do
      Logger.debug("Retrieving #{length(missing_keys)} missing signing keys")

      tasks =
        Enum.map(missing_keys, fn key_id ->
          Task.async(fn ->
            url = "https://github.com/nodejs/release-keys/raw/main/keys/#{key_id}.asc"
            dest = Path.join(keystore_path, "#{key_id}.asc")

            binary = HttpUtils.fetch_body!(url)
            File.write!(dest, binary, [:binary])
            GPGex.cmd!(["--import", dest], keystore: keystore)
            File.rm!(dest)
          end)
        end)

      Task.await_many(tasks, 60000)
    end

    GPGex.cmd!(["--verify", checksums_path], keystore: keystore)

    checksums = File.read!(checksums_path)
    filename = archive_name(version)

    checksum =
      case Regex.named_captures(
             ~r/^(?<checksum>.*?)\s+#{Regex.escape(filename)}$/m,
             checksums
           ) do
        %{"checksum" => checksum} ->
          Base.decode16!(checksum, case: :lower)

        _ ->
          raise "Couldn't find checksum for #{filename} in #{checksums_path}"
      end

    archive_binary = File.read!(archive_path)

    computed_checksum = :crypto.hash(:sha256, archive_binary)

    computed_checksum == checksum or raise "invalid checksum"
  end

  defp fetch_archive(version, archive_base_url) do
    archive_url = get_url(archive_base_url, version)
    %{archive: archive_path} = paths(version)

    Logger.debug("Downloading Node.js from #{archive_url}")
    binary = HttpUtils.fetch_body!(archive_url)
    File.write!(archive_path, binary, [:binary])
  end

  defp fetch_checksums(version) do
    checksums_url = get_url(@signed_checksums_base_url, version)

    %{checksums: checksums_path} = paths(version)

    Logger.debug("Downloading signed checksums from #{checksums_url}")
    binary = HttpUtils.fetch_body!(checksums_url)
    File.write!(checksums_path, binary, [:binary])
  end

  defp name(version), do: "node-v#{version}"
  defp archive_name(version), do: "node-v#{version}-#{target()}.#{extension()}"

  defp paths(version) do
    name = name(version)

    base_path =
      if Code.ensure_loaded?(Mix.Project) do
        Mix.Project.build_path()
      else
        Path.expand("_build")
      end

    base_path = Path.join([base_path, "nodejs"])
    destination = Path.join([base_path, "versions", version])

    %{
      :nodelix => base_path,
      :destination => destination,
      :bin_dir => Path.join(destination, "bin"),
      :archive => Path.join(base_path, archive_name(version)),
      :checksums => Path.join(base_path, "SHASUMS256-#{name}.txt"),
      :signature => Path.join(base_path, "SHASUMS256-#{name}.txt.sig"),
      :keystore => Path.join(base_path, ".gnupg")
    }
  end

  defp target do
    arch_str = :erlang.system_info(:system_architecture)
    [arch | _] = arch_str |> List.to_string() |> String.split("-")

    case {:os.type(), arch, :erlang.system_info(:wordsize) * 8} do
      {{:unix, :aix}, "ppc64", 64} -> "aix-ppc64"
      {{:unix, :darwin}, arch, 64} when arch in ~w(arm aarch64) -> "darwin-arm64"
      {{:unix, :darwin}, "x86_64", 64} -> "darwin-x64"
      {{:unix, :linux}, "aarch64", 64} -> "linux-arm64"
      {{:unix, :linux}, "armv7l", 32} -> "linux-armv7l"
      {{:unix, :linux}, "ppc64le", 64} -> "linux-ppc64le"
      {{:unix, :linux}, "s390x", 32} -> "linux-s390x"
      {{:unix, _osname}, arch, 64} when arch in ~w(x86_64 amd64) -> "linux-x64"
      {{:win32, _}, "aarch64", 64} -> "win-arm64"
      {{:win32, _}, _arch, 64} -> "win-x64"
      {{:win32, _}, _arch, 32} -> "win-x86"
      {_os, _arch, _wordsize} -> raise "Node.js is not available for architecture: #{arch_str}"
    end
  end

  defp extension do
    case :os.type() do
      {:unix, _} -> "tar.gz"
      {:win32, _} -> "zip"
    end
  end

  defp get_url(base_url, version) do
    base_url
    |> String.replace("$version", version)
    |> String.replace("$target", target())
    |> String.replace("$ext", extension())
  end
end
