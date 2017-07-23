#!/bin/bash
mix clean
mix compile
mix compile.protocols --force
iex --sname steno -S mix phx.server
