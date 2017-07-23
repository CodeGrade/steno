defmodule StenoBot.Queue do
  # This is an interface to Steno.Grading.Queue in Steno

  def get() do
    pid = :syn.find_by_key(:grading_queue)
    if pid == :undefined do
      nil
    else
      GenServer.call(pid, :get)
    end
  end
end
