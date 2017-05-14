defmodule Sableye.Mixfile do
  use Mix.Project

  def project do
    [app: :sableye,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:logger, :cowboy, :erlydtl, :plug, :comeonin, :recaptcha,
                     :mariaex, :poison, :earmark, :pot, :ecto],
      mod: {Sableye, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:cowboy, "~> 1.1"},
      {:plug, "~> 1.3"},
      {:erlydtl, github: "erlydtl/erlydtl"},
      {:mariaex, "~> 0.8.2"},
      {:ecto, "~> 2.1"},
      {:comeonin, "~> 3.0"},
      {:recaptcha, "~> 2.1"},
      {:earmark, "~> 1.2"},
      {:pot, "~> 0.9.5"},
      {:distillery, "~> 1.0"}
    ]
  end
end
