#!/bin/bash
mix clean
mix compile
mix compile.protocols --force
iex -S mix phx.server
