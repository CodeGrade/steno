defmodule StenoBot.Queue do
  # This is an interface to Steno.Grading.Queue in Steno

  def run do
    call(:run)
  end

  def get do
    call(:get)
  end

  def done(job) do
    call({:done, job})
  end

  defp call(msg) do
    call(:syn.find_by_key(:grading_queue), msg)
  end

  defp call(:undefined, _) do
    nil
  end

  defp call(pid, msg) do
    GenServer.call(pid, msg)
  end
end
