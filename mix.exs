defmodule Crow.MixProject do
  use Mix.Project

  def project do
    [
      app: :crow,
      version: "0.1.4",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/jchristgit/crow",
      homepage_url: "https://github.com/jchristgit/crow",
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Crow.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Linting dependencies
      {:credo, "~> 1.7", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},

      # Documentation dependencies
      {:ex_doc, "~> 0.28", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      description: "A munin node implementation written in Elixir",
      source_ref: "master",
      licenses: ["ISC"],
      links: %{
        "Documentation" => "https://hexdocs.pm/crow",
        "GitHub" => "https://github.com/jchristgit/crow"
      },
      maintainers: ["Johannes Christ"]
    ]
  end

  defp docs do
    [
      main: "Introduction",
      extras: [
        "guides/Introduction.md"
      ]
    ]
  end
end
