defmodule TaskSystem.TaskManager do
  @moduledoc """
  Entrypoint for adding, listing and stopping tasks
  """

  alias TaskSystem.{
    TaskStorage,
    TaskQueue
  }

  @doc """
  Adds a task to the queue
  """
  @spec add_task(any()) :: pos_integer()
  defdelegate add_task(data),
    to: TaskQueue,
    as: :enqueue

  @doc """
  List tasks being processed
  """
  @spec list_tasks() :: [pos_integer()]
  defdelegate list_tasks,
    to: TaskStorage,
    as: :list_tasks

  @doc """
  Stop a task being processed
  """
  @spec stop_task(pos_integer()) :: :ok | {:error, :task_not_found}
  def stop_task(id) do
    case TaskStorage.get_task(id) do
      %Task{pid: pid} ->
        Process.exit(pid, :normal)
        :ok

      nil ->
        {:error, :task_not_found}
    end
  end

end
