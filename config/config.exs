import Config

config :nodelix,
  version: "20.10.0",
  npm: [
    args: ["_build/dev/nodejs/versions/20.10.0/bin/npm"]
  ],
  another: [
    args: ["--version"]
  ]
