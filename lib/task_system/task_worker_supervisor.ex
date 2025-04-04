defmodule TaskSystem.TaskWorkerSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_init_arg) do
    children = Enum.map(1..5, &{TaskSystem.TaskWorker, &1})
    Supervisor.init(children, strategy: :one_for_one)
  end

end
