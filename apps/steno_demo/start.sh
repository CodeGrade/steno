#!/bin/bash
mix clean
mix compile
mix compile.protocols --force
export ADDR=`perl ./getip.pl`
iex -S mix phx.server
