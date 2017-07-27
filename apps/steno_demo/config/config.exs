# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :steno_demo,
  namespace: StenoDemo,
  ecto_repos: [StenoDemo.Repo],
  env: Mix.env

# Configures the endpoint
config :steno_demo, StenoDemo.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lARNe60r4uAp5CGBmpcar42ktT1cTu7aWH1BCSqVhz0/hIXl1Y8RQ+p5cSKxVBX3",
  render_errors: [view: StenoDemo.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: StenoDemo.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
