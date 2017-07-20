defmodule StenoBot.Sandbox.Sup do
  use GenServer

  alias StenoBot.Sandbox

  ##
  ## interface
  ##

  def start_link(count) do
    GenServer.start_link(__MODULE__, count, name: :sandbox_sup)
  end

  def status() do
    GenServer.call(:sandbox_sup, :status)
  end

  def signal(sb_id) do
    GenServer.call(:sandbox_sup, {:signal, sb_id})
  end

  ##
  ## callbacks
  ##

  def init(count) do
    :erlang.process_flag(:trap_exit, true)
    :syn.join(:bots, self())

    state = %{
      count: count,
      snum: 0,
      kids: :queue.new(),
    }
    {:ok, start_sandboxes(state)}
  end

  def handle_call(:status, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:signal, sb_id}, _from, state) do
    IO.puts "#{node()}: Sandbox id=#{sb_id} ready."
    {:reply, :ok, state}
  end

  def handle_info({:EXIT, pid, _reason}, state) do
    func = fn {sb_id, pp} ->
      if pp == pid do
        Sandbox.cleanup(sb_id)
      end
      pp != pid
    end
    kids  = :queue.filter(func, state.kids)
    state = start_sandboxes(%{state | kids: kids})
    {:noreply, state}
  end

  def terminate(_reason, kids) do
    Enum.each kids, fn {sb_id, _pp} ->
      Sandbox.cleanup(sb_id)
    end
  end

  ###
  ### support
  ##
  defp start_sandboxes(state) do
    if :queue.len(state.kids) < state.count do
      sb_id = state.snum
      {:ok, pid} = Sandbox.start_link(sb_id)
      kids = :queue.snoc(state.kids, {sb_id, pid})
      state = %{ state | snum: sb_id + 1, kids: kids }
      start_sandboxes(state)
    else
      state
    end
  end
end

