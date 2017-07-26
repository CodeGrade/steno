defmodule Steno.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Steno.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Steno.Web.Endpoint, []),
      # Start your own worker by calling: Steno.Worker.start_link(arg1, arg2, arg3)
      # worker(Steno.Worker, [arg1, arg2, arg3]),
      worker(Steno.Grading.Queue, []),
      #worker(Steno.Relay, []),
    ]

    # We're here.
    :net_adm.world()
    :syn.init()

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Steno.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
