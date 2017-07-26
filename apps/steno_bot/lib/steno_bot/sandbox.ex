defmodule StenoBot.Sandbox do
  use GenServer
  ##
  ## interface
  ##
  def start_link(sandbox_id) do
    state0 = %{
      sb_id:  sandbox_id,
      job_id: nil,
      cookie: nil,
      serial: 0,
      output: [],
      active: nil,
      relays: [],
      phase: "preboot",
    }
    GenServer.start_link(__MODULE__, state0)
  end

  def poke(pid) do
    GenServer.cast(pid, :poke)
  end

  def dump(pid) do
    GenServer.call(pid, :dump)
  end

  def subscribe(pid, relay_pid) do
    GenServer.call(pid, {:subscribe, relay_pid})
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

  def handle_cast(:poke, state) do
    if state.active do
      {:noreply, state}
    else
      {:noreply, get_and_run_job(state)}
    end
  end

  def handle_call(:dump, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:subscribe, pid}, _from, state) do
    Enum.each Enum.reverse(state.output), fn item ->
      GenServer.cast(pid, item)
    end
    {:reply, :ok, %{state | relays: [ pid | state.relays ]}}
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
    :syn.register({:job_sandbox, job.id}, self())

    {:ok, fd, path} = Temp.open("driver")
    Temp.track!

    driver = make_driver(job)
    IO.write(fd, driver)
    File.close(fd)

    state = spawn_cmd(state, {"exec", "run-job", [sandbox_name(state.sb_id), path]})

    %{ state | cookie: job.cookie, job_id: job.id }
  end

  defp send_relays(state, msg) do
    Enum.each state.relays, fn pid ->
      GenServer.cast(pid, msg)
    end

    if state.job_id do
      IO.inspect({:msg, msg})
      StenoBot.Queue.relay(state.job_id, inspect(msg))
    end
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

    send_relays(state, {:data, item})
    {:noreply, state}
  end

  def handle_info({_src, :result, result}, state) do
    send_relays(state, {:done, result})

    case state.phase do
      "boot" ->
        state = state
        |> Map.put(:active, nil)
        |> get_and_run_job
        {:noreply, state}
      phase ->
        StenoBot.Queue.done(%{
              id: state.job_id,
              cookie: state.cookie,
              output: format_output(state.output),
        })
        IO.inspect({:stopping, :sandbox_phase, phase})
        {:stop, :normal, state}
    end
  end

  defp format_output(output) do
    grouped = output
    |> Enum.sort_by(fn {n, _, _, _} -> n end)
    |> Enum.group_by(fn {_, _, t, _} -> t end)

    stdout = Enum.map_join(grouped[:out] || [], "", fn {_, _, _, m} -> m end)
    stderr = Enum.map_join(grouped[:err] || [], "", fn {_, _, _, m} -> m end)

    "== stdout ==\n#{stdout}\n== stderr ==\n#{stderr}"
  end
end

