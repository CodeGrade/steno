#!/bin/bash
export MIX_ENV=prod
export PORT=8081

mix clean
mix compile
mix compile.protocols --force
(cd assets && brunch build)
mix phx.digest
iex --sname steno -S mix phx.server
