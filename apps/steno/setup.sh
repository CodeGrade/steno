export MIX_ENV=prod
mix compile
mix ecto.migrate
mix phx.digest
(cd assets && brunch build)
