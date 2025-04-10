defmodule TaskSystem.TaskSupervisor do
  use Supervisor

  @spec start_link(Supervisor.child_spec()) :: Supervisor.on_start()
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init([max_pool_size: max_pool_size]) when is_integer(max_pool_size) do
    Range.new(1, max_pool_size, 1)
    |> Enum.map(&{TaskSystem.TaskWorker, &1})
    |> Supervisor.init(strategy: :one_for_one)
  end

  @impl true
  def init(_init_arg), do: Supervisor.init([], strategy: :one_for_one)

end
