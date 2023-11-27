defmodule Nodelix.NodeDownloader do
  # https://nodejs.org/en/about/previous-releases
  @latest_lts_version "20.10.0"

  @default_archive_base_url "https://nodejs.org/dist/v$version/node-v$version-$target"
  @signed_checksums_base_url "https://nodejs.org/dist/v$version/SHASUMS256.txt.asc"

  @signing_keys_list_url "https://raw.githubusercontent.com/nodejs/release-keys/main/keys.list"

  require Logger

  alias Nodelix.HttpUtils

  @moduledoc false

  @doc """
  TODO
  - [X] fetch Node.js archive for a version and platform (https://nodejs.org/dist/v20.10.0/)
  - [X] fetch checksums file (https://nodejs.org/dist/v20.10.0/SHASUMS256.txt.asc)
  - [X] fetch Node.js signing keys list (https://raw.githubusercontent.com/nodejs/release-keys/main/keys.list)
  - [X] fetch keys (using GPG)
  - [X] verify signature of the checksums file (using GPG)
  - [X] check integrity of the downloaded archive
  - [X] decompress archive (delete destination first, see https://github.com/phoenixframework/tailwind/pull/67)
  - [ ] parameterize (instead of reading config) + refactor/cleanup (stop chaining functions with side-effects,
        use function arguments, and probably more)
  """
  def todo, do: []

  @doc """
  Returns the latest known LTS version at the time of publishing.
  """
  def latest_lts_version, do: @latest_lts_version

  @doc """
  The default URL to fetch the Node.js archive from.
  """
  def default_archive_base_url, do: @default_archive_base_url

  @doc """
  Returns the path to the node executable.

  The executable may not be available if it was not yet installed.
  """
  def bin_path, do: Path.join(Map.get(paths(), :destination), "bin/node")

  @doc """
  Returns the version of the node executable.

  Returns `{:ok, version_string}` on success or `:error` when the executable
  is not available.
  """
  def bin_version do
    path = bin_path()

    with true <- File.exists?(path),
         {out, 0} <- System.cmd(path, ["--version"]),
         [vsn] <- Regex.run(~r/v([^\s]+)/, out, capture: :all_but_first) do
      {:ok, vsn}
    else
      _ -> :error
    end
  end

  @doc """
  Installs Node.js with `configured_version/0`.
  """
  def install(archive_base_url \\ @default_archive_base_url) do
    fetch_archive(archive_base_url)
    fetch_checksums()
    verify_archive!()
    unpack_archive()

    Logger.debug(
      "Succesfully installed Node.js v#{Nodelix.configured_version()} in #{Map.get(paths(), :destination)}"
    )
  end

  defp unpack_archive() do
    %{archive: archive_path, destination: destination, bin_dir: bin_path} = paths()

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
      Path.join(destination, "lib/node_modules/npm/bin/npm-cli.js"),
      Path.join(bin_path, "npm")
    )

    Enum.map(File.ls!(bin_path), &File.chmod!(Path.join(bin_path, &1), 0o755))
  end

  defp remove_leading_dir(path) do
    [_ | rest] = Path.split(path)
    Path.join(rest)
  end

  # - verifies checksums file signature
  # - extracts the corresponding archive checksum
  # - verifies archive checksum matches
  defp verify_archive!() do
    %{archive: archive_path, checksums: checksums_path, keystore: keystore_path} = paths()

    Logger.debug("Downloading signing keys list from #{@signing_keys_list_url}")

    signing_key_ids =
      @signing_keys_list_url
      |> HttpUtils.fetch_body!()
      |> String.trim()
      |> String.split("\n")

    keystore = GPGex.Keystore.get_keystore(path: keystore_path)

    missing_keys =
      signing_key_ids
      |> Enum.filter(fn key_id ->
        with {:error, _, _, _} <- GPGex.cmd(["--list-keys", key_id], keystore: keystore) do
          true
        else
          _ -> false
        end
      end)

    if length(missing_keys) > 0 do
      Logger.debug("Using GPG to retrieve #{length(missing_keys)} missing signing keys")

      {messages, _} =
        GPGex.cmd!(["--keyserver", "hkps://keys.openpgp.org", "--recv-keys"] ++ missing_keys,
          keystore: keystore
        )

      imported_keys =
        Enum.flat_map(messages, fn msg ->
          case String.starts_with?(msg, "IMPORT_OK") do
            true ->
              [_, _, key_id] = String.split(msg, " ", parts: 3)
              [key_id]

            false ->
              []
          end
        end)

      still_missing_keys = missing_keys -- imported_keys

      # because some keys are unverified on keys.openpgp.org,
      # we make a subsequent call to the Ubuntu keyserver
      GPGex.cmd!(
        ["--keyserver", "hkps://keyserver.ubuntu.com", "--recv-keys"] ++ still_missing_keys,
        keystore: keystore
      )
    end

    GPGex.cmd!(["--verify", checksums_path], keystore: keystore)

    checksums = File.read!(checksums_path)

    checksum =
      case Regex.named_captures(
             ~r/^(?<checksum>.*?)\s+#{Regex.escape("#{name()}-#{target()}")}$/m,
             checksums
           ) do
        %{"checksum" => checksum} ->
          Base.decode16!(checksum, case: :lower)

        _ ->
          raise "Couldn't find checksum for node-v#{Nodelix.configured_version()}-#{target()} in #{checksums_path}"
      end

    archive_binary = File.read!(archive_path)

    computed_checksum = :crypto.hash(:sha256, archive_binary)

    computed_checksum == checksum or raise "invalid checksum"
  end

  defp fetch_archive(archive_base_url) do
    archive_url = get_url(archive_base_url)
    %{archive: archive_path} = paths()

    Logger.debug("Downloading Node.js from #{archive_url}")
    binary = HttpUtils.fetch_body!(archive_url)
    File.write!(archive_path, binary, [:binary])
  end

  defp fetch_checksums() do
    checksums_url = get_url(@signed_checksums_base_url)

    %{checksums: checksums_path} = paths()

    Logger.debug("Downloading signed checksums from #{checksums_url}")
    binary = HttpUtils.fetch_body!(checksums_url)
    File.write!(checksums_path, binary, [:binary])
  end

  defp paths do
    name = name()

    base_path =
      if Code.ensure_loaded?(Mix.Project) do
        Path.dirname(Mix.Project.build_path())
      else
        Path.expand("_build")
      end

    base_path = Path.join([base_path, "nodelix"])

    File.mkdir_p!(base_path)

    destination = Path.join([base_path, "versions", Nodelix.configured_version()])

    %{
      :destination => destination,
      :bin_dir => Path.join(destination, "bin"),
      :archive => Path.join(base_path, "#{name}-#{target()}"),
      :checksums => Path.join(base_path, "SHASUMS256-#{name}.txt"),
      :signature => Path.join(base_path, "SHASUMS256-#{name}.txt.sig"),
      :keystore => Path.join(base_path, ".gnupg")
    }
  end

  defp name, do: "node-v#{Nodelix.configured_version()}"

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
