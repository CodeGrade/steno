defmodule StenoBot.Sandbox do
  use GenServer
  ##
  ## interface
  ##
  def start_link(sandbox_id) do
    state0 = %{
      sb_id:  sandbox_id,
      serial: 0,
      output: [],
      queue:  :queue.from_list([]),
      active: nil,
      ondata: nil,
      phase:  "preboot",
    }
    GenServer.start_link(__MODULE__, state0)
  end

  def listen(pid, ondata) do
    GenServer.call(pid, {:listen, ondata})
  end

  def exec(pid, phase, cmd) do
    GenServer.call(pid, {:exec, phase, cmd})
  end

  def push(pid, src, dst) do
    GenServer.call(pid, {:push, src, dst})
  end

  def dump(pid) do
    GenServer.call(pid, :dump)
  end

  def idle?(pid) do
    GenServer.call(pid, :idle?)
  end

  def wait_idle(pid) do
    if idle?(pid) do
      :ok
    else
      :timer.sleep(100)
      wait_idle(pid)
    end
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  def cleanup(sandbox_id) do
    script = script_path("stop")
    sbname = sandbox_name(sandbox_id)
    cmd    = ~s(bash "#{script}" "#{sbname}")
    Porcelain.shell(cmd)
  end

  ##
  ## implementation
  ##
  def init(state) do
    state = state
    |> queue_add({"launch", "boot", [sandbox_name(state.sb_id)]})
    |> spawn_next
    {:ok, state}
  end

  def handle_call({:listen, ondata}, _from, state) do
    Enum.each state.output, fn item ->
      ondata.(item)
    end
    {:reply, :ok, %{state | ondata: ondata}}
  end

  def handle_call({:exec, phase, cmd}, _from, state) do
    sbname = sandbox_name(state.sb_id)
    state = state
    |> queue_add({"exec", phase, [sbname, cmd]})
    |> spawn_next
    {:reply, :ok, state}
  end

  def handle_call({:push, src, dst}, _from, state) do
    sbname = sandbox_name(state.sb_id)
    state = state
    |> queue_add({"push", "push", [sbname, src, dst]})
    |> spawn_next
    {:reply, :ok, state}
  end

  def handle_call(:dump, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:idle?, _from, state) do
    {:reply, (!state.active && :queue.is_empty(state.queue)), state}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, {:ok, state}, state}
  end

  defp queue_add(state, item) do
    %{ state | queue: :queue.snoc(state.queue, item) }
  end

  def get_and_run_job(state) do
    job = StenoBot.Queue.get()
    if job do
      run_job(state, job)
    else
      state
    end
  end

  def run_job(state, job) do
    IO.inspect(job)
    IO.puts(make_driver(job))
    state
  end

  defp spawn_cmd({script, phase, args}) do
    args1 = Enum.join(Enum.map(args, &(~s["#{&1}"])), " ")

    proc = Porcelain.spawn_shell(
      ~s[bash "#{script_path(script)}" #{args1}],
      out: {:send, self()},
      err: {:send, self()})

    {:ok, proc, phase}
  end

  defp spawn_next(state) do
    if !state.active && :queue.is_empty(state.queue) do
      StenoBot.Sandbox.Sup.signal(state.sb_id)
    end

    if state.active || :queue.is_empty(state.queue) do
      state
    else
      next = :queue.get(state.queue)
      {:ok, proc, phase} = spawn_cmd(next)

      state
      |> Map.put(:queue,  :queue.drop(state.queue))
      |> Map.put(:active, proc)
      |> Map.put(:phase,  phase)
    end
  end

  defp script_path(name) do
    base = Application.app_dir(:steno_bot, "priv")
    "#{base}/scripts/#{name}.sh"
  end

  def reap_old() do
    base = Application.app_dir(:steno_bot, "priv")
    {_, 0} = System.cmd("ruby", ["#{base}/scripts/reap.rb"])
  end

  defp sandbox_name_base() do
    node_name = Regex.replace(~r{@}, to_string(node()), "-")
    "steno-#{node_name}"
  end

  defp sandbox_name(sandbox_id) do
    "#{sandbox_name_base()}-#{sandbox_id}"
  end

  def make_driver(job) do
    job = job
    |> Map.drop(:__struct__, :__meta__)
    |> Map.put(:timeout, 60)
    |> Map.put(:cookie, :crypto.strong_rand_bytes(16) |> Base.encode16)
    |> Enum.into([])
    base = Application.app_dir(:steno_bot, "priv")
    EEx.eval_file("#{base}/scripts/driver.pl.eex", Enum.into(job, []))
  end

  ##
  ## callbacks from porcelain
  ##
  def handle_info({_src, :data, stream, data}, state) do
    serial = state.serial + 1
    item   = {serial, state.phase, stream, data}
    state  = state
    |> Map.put(:output, [ item | state.output ])
    |> Map.put(:serial, serial)
    if state.ondata do
      state.ondata.({:data, item})
    end
    {:noreply, state}
  end

  def handle_info({_src, :result, result}, state) do
    state = state
    |> Map.put(:active, nil)
    |> spawn_next
    if state.ondata do
      state.ondata.({:done, result})
    end
    {:noreply, state}
  end
end

