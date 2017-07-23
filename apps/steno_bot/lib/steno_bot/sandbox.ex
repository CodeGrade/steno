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
      active: nil,
      ondata: nil,
      phase: "preboot",
    }
    GenServer.start_link(__MODULE__, state0)
  end

  def listen(pid, ondata) do
    GenServer.call(pid, {:listen, ondata})
  end

  def idle?(pid) do
    GenServer.call(pid, :idle?)
  end

  def poke(pid) do
    GenServer.call(pid, :poke)
  end

  def dump(pid) do
    GenServer.call(pid, :dump)
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
    cmd = {"boot", "launch", [sandbox_name(state.sb_id)]}
    state = spawn_cmd(state, cmd)
    {:ok, state}
  end

  def handle_call({:listen, ondata}, _from, state) do
    Enum.each Enum.reverse(state.output), fn item ->
      ondata.(item)
    end
    {:reply, :ok, %{state | ondata: ondata}}
  end

  def handle_call(:poke, _from, state) do
    if !state.active do
      {:reply, :ok, get_and_run_job(state)}
    else
      {:reply, :ok, state}
    end
  end

  def handle_call(:dump, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:exec, phase, cmd}, _from, state) do
    sbname = sandbox_name(state.sb_id)
    state = spawn_cmd(state, {phase, "exec", [sbname, cmd]})
    {:reply, :ok, state}
  end

  def handle_call({:push, src, dst}, _from, state) do
    sbname = sandbox_name(state.sb_id)
    state = spawn_cmd(state, {"push", "push", [sbname, src, dst]})
    {:reply, :ok, state}
  end

  def handle_call(:idle?, _from, state) do
    {:reply, !state.active, state}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, {:ok, state}, state}
  end

  defp spawn_cmd(state, {phase, script, args}) do
    args1 = Enum.join(Enum.map(args, &(~s["#{&1}"])), " ")

    proc = Porcelain.spawn_shell(
      ~s[bash "#{script_path(script)}" #{args1}],
      out: {:send, self()},
      err: {:send, self()})

    state
    |> Map.put(:active, proc)
    |> Map.put(:phase, phase)
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
    base = Application.app_dir(:steno_bot, "priv")
    EEx.eval_file("#{base}/scripts/driver.pl.eex", Enum.into(job, []))
  end

  defp get_and_run_job(state) do
    case StenoBot.Queue.get() do
      {:ok, job} ->
        IO.inspect(job)
        run_job(state, job)
      _else ->
        IO.inspect("No jobs");
        state
    end
  end

  defp run_job(state, job) do
    {:ok, fd, path} = Temp.open("driver")
    driver = make_driver(job)
    IO.puts(driver)
    IO.write(fd, driver)
    File.close(fd)


    state = spawn_cmd(state, {"exec", "run-job", [sandbox_name(state.sb_id), path]})

    File.rm(path)
    state
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
    if state.ondata do
      state.ondata.({:done, result})
    end

    case state.phase do
      "boot" ->
        state = state
        |> Map.put(:active, nil)
        |> get_and_run_job
        {:noreply, state}
      _ ->
        {:stop, :normal, state}
    end
  end
end

