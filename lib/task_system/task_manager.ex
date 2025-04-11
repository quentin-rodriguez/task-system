defmodule TaskSystem.TaskManager do
  @moduledoc """

  """

  alias TaskSystem.{
    TaskStorage,
    TaskQueue
  }

  @doc """

  """
  @spec add_task(any()) :: pos_integer()
  defdelegate add_task(data),
    to: TaskQueue,
    as: :enqueue

  @doc """

  """
  @spec list_tasks() :: [pos_integer()]
  defdelegate list_tasks,
    to: TaskStorage,
    as: :list_tasks

  @doc """

  """
  @spec stop_task(pos_integer()) :: :ok | {:error, :task_not_found}
  def stop_task(id) do
    case TaskStorage.get_task(id) do
      %Task{pid: pid} ->
        Process.exit(pid, {:kill, id})
        :ok

      nil ->
        {:error, :task_not_found}
    end
  end

end
