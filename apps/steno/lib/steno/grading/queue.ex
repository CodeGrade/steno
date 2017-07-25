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

  def get do
    GenServer.call(:grading_queue, :get)
  end

  def done(job) do
    GenServer.call(:grading_queue, {:done, job})
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

  def handle_call({:done, res}, _from, state) do
    IO.inspect({:queue, :done, res})
    if res.output do
      IO.puts res.output
    end

    if res.id do
      Steno.Grading.get_job!(res.id)
      |> Steno.Grading.update_job(res)
    end
    {:reply, :ok, state}
  end
end
