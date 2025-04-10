defmodule TaskSystem do
  @moduledoc """
  Documentation for `TaskSystem`.
  """

  alias TaskSystem.{
    TaskStorage,
    TaskQueue
  }

  @spec add_task(any()) :: pos_integer()
  defdelegate add_task(data),
    to: TaskQueue,
    as: :enqueue

  @spec list_tasks() :: %{pos_integer() => Task.t()}
  defdelegate list_tasks,
    to: TaskStorage,
    as: :list_tasks

  @spec stop_task(pos_integer()) :: :ok | {:error, :not_found}
  def stop_task(id) do
    case TaskStorage.get_task(id) do
      %Task{pid: pid} ->
        Process.exit(pid, {:kill, id})
        :ok

      nil ->
        {:error, :not_found}
    end
  end


end
