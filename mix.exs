defmodule Barlix.Mixfile do
  use Mix.Project

  @version "0.3.3"

  def project do
    [app: :barlix,
     version: @version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "Barcode generator",
     package: package(),
     docs: docs(),
     dialyzer: [plt_add_deps: :transitive],
     deps: deps()]
  end

  def application do
    [applications: [:logger, :png]]
  end

  defp deps do
    [{:png, "~> 0.1"},
     {:ex_doc, "~> 0.14", only: :dev},
     {:mix_test_watch, "~> 0.2", only: :dev},
     {:tempfile, "~> 0.1.0", only: :test},
     {:excheck, "~> 0.5", only: :test},
     {:triq, github: "triqng/triq", only: :test}]
  end

  defp package do
    %{licenses: ["MIT"],
      links: %{"Github" => "https://github.com/ananthakumaran/barlix"},
      maintainers: ["ananthakumaran@gmail.com"]}
  end

  defp docs do
    [source_url: "https://github.com/ananthakumaran/barlix",
     source_ref: "v#{@version}",
     main: Barlix,
     extras: ["README.md"]]
  end
end
