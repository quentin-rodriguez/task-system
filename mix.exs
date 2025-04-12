defmodule TaskSystem.MixProject do
  use Mix.Project

  def project do
    [
      app: :task_system,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: extra_applications(Mix.env()),
      mod: {TaskSystem.Application, []}
    ]
  end

  defp extra_applications(:prod), do: [:logger]
  defp extra_applications(_), do: [:logger, :wx, :observer]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end

end
