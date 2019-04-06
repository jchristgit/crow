defmodule Crow.MixProject do
  use Mix.Project

  def project do
    [
      app: :crow,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/jchristgit/crow",
      homepage_url: "https://github.com/jchristgit/crow",
      deps: deps(),
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

  def package do
    [
      description: "A munin node implementation written in Elixir",
      licenses: ["ISC"],
      links: %{
        "Documentation" => "https://hexdocs.pm/crow",
        "GitHub" => "https://github.com/jchristgit/crow"
      },
      maintainers: ["Johannes Christ"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Linting dependencies
      {:credo, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: :dev, runtime: false},

      # Documentation dependencies
      {:ex_doc, "~> 0.20", only: :dev, runtime: false}
    ]
  end
end
