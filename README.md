# Nodelix

Seamless Node.js in Elixir.

Provides Mix tasks for the installation and execution of Node.js.

This project is currently not recommended for production Elixir use.
Its main purpose is to offer a straightforward interface for utilizing Node.js and npm libraries within Mix tasks.

Full documentation can be found at [https://hexdocs.pm/nodelix](https://hexdocs.pm/nodelix).

## Installation

`gpg` must be available in your PATH to verify the signature of Node.js releases.

The package can be installed by adding `nodelix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:nodelix, "1.0.0-alpha.3", only: :dev, runtime: false}
  ]
end
```

Once installed, change your `config/config.exs` to pick your
Node.js version of choice:

```elixir
config :nodelix, version: "20.10.0"
```

Now you can install Node.js by running:

```shell
$ mix nodelix.install
```

And invoke Node.js with:

```shell
$ mix nodelix default some-script.js --some-option
```

The Node.js installation is located at `_build/dev/nodejs/versions/$VERSION`.

## Profiles

You can define multiple nodelix profiles. By default, there is a
profile called `:default` which you can configure its args, current
directory and environment:

      config :nodelix,
        version: "20.10.0",
        default: [
          args: ~w(
            some-script.js
            --some-option
          ),
          cd: Path.expand("../assets", __DIR__),
        ]

The default current directory is your project's root.

When `mix nodelix default` is invoked, the task arguments will be appended
to the ones configured above.

## Versioning

This project follows the principles of [Semantic Versioning (SemVer)](https://semver.org/).

## Credits

Based on the code from [`tailwind`](https://github.com/phoenixframework/tailwind) (v0.2.2).
For licensing and copyright details, refer to the [`LICENSE` file](./LICENSE.md).
