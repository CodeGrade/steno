use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :steno_demo, StenoDemo.Web.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :steno_demo, StenoDemo.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "steno",
  password: "Vos2yei3ri2L",
  database: "steno_demo_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
