defmodule StenoBot.Mixfile do
  use Mix.Project

  def project do
    [app: :steno_bot,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {StenoBot.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:my_app, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:porcelain, "~> 2.0"},
     {:syn, "~> 1.6"},
     {:temp, "~> 0.4"}]
  end

  defp aliases do
    ["deps.get": [&get_goon/1, "deps.get"]]
  end

  defp get_goon(_) do
    unless File.exists?("goon") do
      goon_url = "https://github.com/alco/goon/releases/download/v1.1.1/goon_linux_amd64.tar.gz"
      System.cmd("bash", ["-c", "wget -O /tmp/goon.tar.gz #{goon_url}"])
      System.cmd("bash", ["-c", "(cd /tmp && tar xzf goon.tar.gz)"])
      System.cmd("bash", ["-c", "cp /tmp/goon ."])
    end
  end
end
