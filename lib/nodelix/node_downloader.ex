defmodule Nodelix.NodeDownloader do
  @moduledoc """
  TODO
  - fetch Node.js archive for a version and platform (https://nodejs.org/dist/v20.10.0/)
  - fetch checksum file (https://nodejs.org/dist/v20.10.0/SHASUMS256.txt)
  - fetch checksum file signature (https://nodejs.org/dist/v20.10.0/SHASUMS256.txt.sig)
  - fetch Node.js signing keys list (https://raw.githubusercontent.com/nodejs/release-keys/main/keys.list)
  - fetch keys (https://raw.githubusercontent.com/nodejs/release-keys/main/keys/4ED778F539E3634C779C87C6D7062848A1AB005C.asc)
  - convert keys to PEM (https://stackoverflow.com/questions/10966256/erlang-importing-gpg-public-key)
  - check signature of the checksum file with each key until there's a match
  - match the hash for the archive filename
  - check integrity of the downloaded archive
  - return the archive
  """
end
