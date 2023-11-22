defmodule Nodelix.MixProject do
  use Mix.Project

  @version "0.0.0-alpha"
  @source_url "https://github.com/sheerlox/nodelix"

  def project do
    [
      app: :nodelix,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
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

  defp deps do
    []
  end
end
