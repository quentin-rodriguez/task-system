defmodule TaskSystem.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TaskSystem.TaskStorage,
      TaskSystem.TaskQueue,
      {Registry, keys: :unique, name: TaskSystem.TaskWorkerRegistry},
      {TaskSystem.TaskSupervisor, max_pool_size: 5},
      {Bandit, scheme: :http, plug: TaskSystem.TaskApi, port: 4000}
    ]


    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TaskSystem.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
