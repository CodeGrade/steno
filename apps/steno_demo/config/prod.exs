use Mix.Config

# For production, we often load configuration from external
# sources, such as your system environment. For this reason,
# you won't find the :http configuration below, but set inside
# StenoDemo.Web.Endpoint.load_from_system_env/1 dynamically.
# Any dynamic configuration should be moved to such function.
#
# Don't forget to configure the url host to something meaningful,
# Phoenix uses this information when generating URLs.
#
# Finally, we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.
config :steno_demo, StenoDemo.Web.Endpoint,
  on_init: {Demo.Web.Endpoint, :load_from_system_env, []},
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :steno_demo, StenoDemo.Web.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :steno_demo, StenoDemo.Web.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :steno_demo, StenoDemo.Web.Endpoint, server: true
#

# Finally import the config/prod.secret.exs
# which should be versioned separately.
#import_config "prod.secret.exs"
get_secret = fn name ->
  confdir = Path.expand("~/.config/steno")
  unless File.dir?(confdir) do
    :ok = File.mkdir_p(confdir)
  end

  secret = Path.join(confdir, "#{name}.secret")
  unless File.exists?(secret) do
    :ok = File.write(secret, :crypto.strong_rand_bytes(16) |> Base.encode16)
  end
  File.read(secret)
end

config :steno_demo, StenoDemo.Web.Endpoint,
  secret_key_base: get_secret.("base")

# Configure your database
config :steno_demo, StenoDemo.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "steno",
  password: get_secret.("dbpass"),
  database: "steno_demo_prod",
  pool_size: 15
