defmodule Steno.Relay do
  use GenServer

  ###
  ### genserver callbacks
  ###

  def init(state) do
    :ok = :syn.register(:steno_relay, self())
    {:ok, state}
  end

end

