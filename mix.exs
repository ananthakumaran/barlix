defmodule Barlix.Mixfile do
  use Mix.Project

  @source_url "https://github.com/ananthakumaran/barlix"
  @version "0.6.4"

  def project do
    [
      app: :barlix,
      version: @version,
      elixir: "~> 1.12",
      deps: deps(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [docs: :docs]
    ]
  end

  def application do
    [extra_applications: [:logger, :eex]]
  end

  defp deps do
    [
      {:png, "~> 0.2"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:briefly, "~> 0.5.0", only: :test},
      {:stream_data, "~> 1.0", only: [:test, :dev]}
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
end
