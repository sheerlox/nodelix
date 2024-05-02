defmodule Nodelix.MixProject do
  use Mix.Project

  @version "1.0.0-alpha.10"
  @source_url "https://github.com/sheerlox/nodelix"

  def project do
    [
      app: :nodelix,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [
        :crypto,
        :logger,
        :public_key,
        inets: :optional,
        ssl: :optional
      ],
      mod: {Nodelix, []},
      env: [default: []]
    ]
  end

  defp deps do
    [
      {:gpg_ex, "1.0.0-alpha.4"},
      {:castore, "~> 1.0"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp dialyzer() do
    [
      plt_add_apps: [:mix, :inets],
      plt_local_path: "priv/plts/project.plt",
      plt_core_path: "priv/plts/core.plt"
    ]
  end

  defp description() do
    """
    Seamless Node.js in Elixir.
    """
  end

  defp package() do
    [
      maintainers: ["Pierre Cavin"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs() do
    [
      name: "Nodelix",
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/nodelix",
      extras: ["README.md", "CHANGELOG.md", "LICENSE.md"]
    ]
  end
end
