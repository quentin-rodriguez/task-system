defmodule TaskSystem.TaskWorkerSupervisor do
  use Supervisor

  @max_pool_size Application.compile_env(:task_system, :max_pool_size, 5)

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_init_arg) do
    children = Enum.map(1..@max_pool_size, &{TaskSystem.TaskWorker, &1})

    Supervisor.init(children, strategy: :one_for_one)
  end

end
