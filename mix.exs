defmodule Barlix.Mixfile do
  use Mix.Project

  @source_url "https://github.com/ananthakumaran/barlix"
  @version "0.6.3"

  def project do
    [
      app: :barlix,
      version: @version,
      elixir: "~> 1.8",
      deps: deps(),
      docs: docs(),
      package: package(),
      dialyzer: dialyzer(),
      preferred_cli_env: [docs: :docs]
    ]
  end

  def application do
    [extra_applications: [:logger, :eex]]
  end

  defp deps do
    [
      {:png, "~> 0.2"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:tempfile, "~> 0.1.0", only: :test},
      {:excheck, "~> 0.6.0", only: :test},
      {:triq, "~> 1.3", only: :test}
    ]
  end

  defp package do
    [
      description: "Barcode generator",
      licenses: ["MIT"],
      maintainers: ["ananthakumaran@gmail.com"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      assets: "assets",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end

  defp dialyzer do
    [
      plt_add_deps: :transitive,
      flags: [:unmatched_returns, :error_handling],
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end
end
