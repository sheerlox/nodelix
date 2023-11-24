defmodule Nodelix.NodeDownloader do
  # https://nodejs.org/en/about/previous-releases
  @latest_lts_version "20.10.0"

  require Logger

  @moduledoc """
  TODO
  - [X] fetch Node.js archive for a version and platform (https://nodejs.org/dist/v20.10.0/)
  - [ ] fetch checksum file (https://nodejs.org/dist/v20.10.0/SHASUMS256.txt)
  - [ ] fetch checksum file signature (https://nodejs.org/dist/v20.10.0/SHASUMS256.txt.sig)
  - [ ] fetch Node.js signing keys list (https://raw.githubusercontent.com/nodejs/release-keys/main/keys.list)
  - [ ] fetch keys (https://raw.githubusercontent.com/nodejs/release-keys/main/keys/4ED778F539E3634C779C87C6D7062848A1AB005C.asc)
  - [ ] convert keys to PEM (https://stackoverflow.com/questions/10966256/erlang-importing-gpg-public-key)
  - [ ] check signature of the checksum file with each key until there's a match
  - [ ] match the hash for the archive filename
  - [ ] check integrity of the downloaded archive
  - [ ] return the archive
  """

  @doc """
  Returns the latest known LTS version at the time of publishing.
  """
  def latest_lts_version, do: @latest_lts_version

  @doc """
  Returns the path to the executable.

  The executable may not be available if it was not yet installed.
  """
  def bin_path, do: archive_path()

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
  Returns the path to the archive.

  The archive may not be available if it was not yet installed.
  """
  def archive_path do
    name = "nodejs-#{target()}"

    if Code.ensure_loaded?(Mix.Project) do
      Path.join(Path.dirname(Mix.Project.build_path()), name)
    else
      Path.expand("_build/#{name}")
    end
  end

  @doc """
  The default URL to fetch the Node.js archive from.
  """
  def default_base_url do
    "https://nodejs.org/dist/v$version/node-v$version-$target"
  end

  @doc """
  Installs Node.js with `configured_version/0`.
  """
  def install(base_url \\ default_base_url()) do
    url = get_url(base_url)
    archive_path = archive_path()
    binary = fetch_body!(url)
    File.mkdir_p!(Path.dirname(archive_path))

    # MacOS doesn't recompute code signing information if a binary
    # is overwritten with a new version, so we force creation of a new file
    if File.exists?(archive_path) do
      File.rm!(archive_path)
    end

    File.write!(archive_path, binary, [:binary])
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

  defp fetch_body!(url) do
    scheme = URI.parse(url).scheme
    url = String.to_charlist(url)
    Logger.debug("Downloading Node.js from #{url}")

    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)

    if proxy = proxy_for_scheme(scheme) do
      %{host: host, port: port} = URI.parse(proxy)
      Logger.debug("Using #{String.upcase(scheme)}_PROXY: #{proxy}")
      set_option = if "https" == scheme, do: :https_proxy, else: :proxy
      :httpc.set_options([{set_option, {{String.to_charlist(host), port}, []}}])
    end

    # https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/inets
    cacertfile = cacertfile() |> String.to_charlist()

    http_options =
      [
        ssl: [
          verify: :verify_peer,
          cacertfile: cacertfile,
          depth: 2,
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ],
          versions: protocol_versions()
        ]
      ]
      |> maybe_add_proxy_auth(scheme)

    options = [body_format: :binary]

    case :httpc.request(:get, {url, []}, http_options, options) do
      {:ok, {{_, 200, _}, _headers, body}} ->
        body

      other ->
        raise """
        Couldn't fetch #{url}: #{inspect(other)}

        This typically means we cannot reach the source or you are behind a proxy.
        You can try again later and, if that does not work, you might:

          1. If behind a proxy, ensure your proxy is configured and that
             your certificates are set via the cacerts_path configuration

          2. Manually download the executable from the URL above and
             place it inside "_build/node-#{target()}"
        """
    end
  end

  defp proxy_for_scheme("http") do
    System.get_env("HTTP_PROXY") || System.get_env("http_proxy")
  end

  defp proxy_for_scheme("https") do
    System.get_env("HTTPS_PROXY") || System.get_env("https_proxy")
  end

  defp maybe_add_proxy_auth(http_options, scheme) do
    case proxy_auth(scheme) do
      nil -> http_options
      auth -> [{:proxy_auth, auth} | http_options]
    end
  end

  defp proxy_auth(scheme) do
    with proxy when is_binary(proxy) <- proxy_for_scheme(scheme),
         %{userinfo: userinfo} when is_binary(userinfo) <- URI.parse(proxy),
         [username, password] <- String.split(userinfo, ":") do
      {String.to_charlist(username), String.to_charlist(password)}
    else
      _ -> nil
    end
  end

  defp cacertfile() do
    Application.get_env(:nodelix, :cacerts_path) || CAStore.file_path()
  end

  defp protocol_versions do
    if otp_version() < 25, do: [:"tlsv1.2"], else: [:"tlsv1.2", :"tlsv1.3"]
  end

  defp otp_version do
    :erlang.system_info(:otp_release) |> List.to_integer()
  end

  defp get_url(base_url) do
    base_url
    |> String.replace("$version", Nodelix.configured_version())
    |> String.replace("$target", target())
  end
end
