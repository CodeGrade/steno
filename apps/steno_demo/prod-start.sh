#!/bin/bash
export MIX_ENV=prod
export PORT=8080

mix clean
mix compile
mix compile.protocols --force
(cd assets && brunch build)
mix phx.digest
iex -S mix phx.server
