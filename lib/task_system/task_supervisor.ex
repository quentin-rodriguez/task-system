defmodule TaskSystem.TaskSupervisor do
  @moduledoc """
  A supervisor for `TaskSystem.TaskWorker` instances

  Batch of workers can be started using `start_link/1` and manage the number of workers with the parameter `:max_pool_size`.
  If the parameter is empty or contains an integer no worker will be created e.g.

    {:ok, pid} = #{__MODULE__}.start_link(max_pool_size: 5)


  Note that an idea for further development could be to scale the number of workers automatically.
  """

  use Supervisor

  @doc false
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
