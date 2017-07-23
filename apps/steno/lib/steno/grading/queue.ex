defmodule Steno.Grading.Queue do
  use GenServer

  ##
  ## interface
  ##

  def start_link do
    GenServer.start_link(__MODULE__, [], name: :grading_queue)
  end

  def run do
    GenServer.call(:grading_queue, :run)
  end

  ##
  ## implementation
  ##

  def init(state) do
    :ok = :syn.register(:grading_queue, self())
    {:ok, state}
  end

  def handle_call(:run, _from, state) do
    Enum.each :syn.get_members(:bots), fn bsup ->
      GenServer.call(bsup, :poke)
    end
    {:reply, :ok, state}
  end

  def handle_call(:get, _from, state) do
    job = Steno.Grading.checkout_job()
    {:reply, job, state}
  end
end
