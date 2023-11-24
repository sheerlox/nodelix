defmodule Nodelix.MixProject do
  use Mix.Project

  @version "1.0.0-alpha.3"
  @source_url "https://github.com/sheerlox/nodelix"

  def project do
    [
      app: :nodelix,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
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
      extras: ["README.md", "CHANGELOG.md", "LICENSE"]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
