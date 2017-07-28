#!/bin/bash
mix clean
mix compile
mix compile.protocols --force
iex --sname steno_bot -S mix
