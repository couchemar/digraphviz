defmodule Digraphviz.MixProject do
  use Mix.Project

  @github "https://github.com/couchemar/digraphviz"

  def project do
    [
      app: :digraphviz,
      version: "0.3.0",
      elixir: "~> 1.7",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @github,
      homepage_url: @github,
      description: """
      Tiny :digraph to .dot converter
      """,
      docs: [
        extras: ["README.md"]
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Andrey Pavlov"],
      licenses: ["MIT"],
      links: %{github: @github}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:exsync, "~> 0.2.3", only: :dev},
      {:ex_doc, "~> 0.19.1", only: :dev}
    ]
  end
end
