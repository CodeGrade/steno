defmodule StenoQueue.Queue do
  use GenServer

  @name {:via, :syn, :grading_queue}

  ###
  ### "Server" interface.
  ###

  def start_link do
    state0 = %{
      jobs: :queue.new(),
    }
    GenServer.start_link(__MODULE__, state0, @name)
  end

  ###
  ### "Client" interface.
  ###

  def submit(job, on_data) do
    GenServer.call(@name, {:submit, job, on_data})
  end

  def get() do
    GenServer.call(@name, :get)
  end

  ###
  ### Implementation.
  ###

  def init(state) do
    {:ok, state}
  end

  def handle_call({:submit, job, on_data}, _from, state) do

  end

  def handle_call(:get, _from, state) do

  end
end
