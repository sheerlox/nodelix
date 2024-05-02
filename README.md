# Nodelix

[![Hex.pm Version](https://img.shields.io/hexpm/v/nodelix.svg)](https://hex.pm/packages/nodelix)
[![Hex.pm Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/nodelix/)
[![Hex.pm Downloads](https://img.shields.io/hexpm/dw/nodelix.svg)](https://hex.pm/packages/nodelix)
[![Last Commit](https://img.shields.io/github/last-commit/sheerlox/nodelix.svg)](https://github.com/sheerlox/nodelix/)

Seamless Node.js in Elixir.

> **⚠️ WARNING**
>
> This is a pre-release version. As such, anything _may_ change
> at any time, the public API _should not_ be considered stable,
> and using a pinned version is _recommended_.

Provides Mix tasks for the installation and execution of Node.js.

This project is currently not recommended for production Elixir use.
Its main purpose is to offer a straightforward interface for utilizing Node.js and npm libraries within Mix tasks.

## Installation

`gpg` must be available in your PATH to verify the signature of Node.js releases.

The package can be installed by adding `nodelix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:nodelix, "1.0.0-alpha.10", only: :dev, runtime: false}
  ]
end
```

Now you can install Node.js by running:

```shell
$ mix nodelix.install --version 18.18.2
```

And invoke Node.js with:

```shell
$ mix nodelix --version 18.18.2 some-script.js --some-option
```

If you omit the `--version` flag, the latest known
[LTS version](https://nodejs.org/en/about/previous-releases) at the
time of publishing will used.

The Node.js installation is located at `_build/dev/nodejs/versions/$VERSION`.

## Nodelix configuration

There is one global configuration for the nodelix application:

- `:cacerts_path` - the directory to find certificates for
  https connections

## Profiles

You can define multiple nodelix profiles. There is a default empty profile
which you can configure its args, current directory and environment:

```elixir
config :nodelix,
  default: [
    args: ~w(
      some-script.js
      --some-option
    ),
    cd: Path.expand("../assets", __DIR__),
  ],
  custom: [
    args: ~w(
      another-script.js
      --another-option
    ),
    cd: Path.expand("../assets/scripts", __DIR__),
    env: [
      NODE_DEBUG: "*"
    ]
  ]
```

The default current directory is your project's root.

To use a profile other than `default`, you can use the `--profile` option:

```shell
mix nodelix --profile custom
```

When `mix nodelix` is invoked, the task arguments will
be appended to the ones configured in the profile.

## Versioning

This project follows the principles of [Semantic Versioning (SemVer)](https://semver.org/).

## Credits

Based on the code from [`tailwind`](https://github.com/phoenixframework/tailwind) (v0.2.2).
For licensing and copyright details, refer to the [`LICENSE` file](./LICENSE.md).
