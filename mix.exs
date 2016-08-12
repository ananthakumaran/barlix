defmodule Barlix.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :barlix,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :png]]
  end

  defp deps do
    [{:png, "~> 0.1"}]
  end
end
