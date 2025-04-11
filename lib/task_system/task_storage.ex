defmodule TaskSystem.TaskStorage do
  @moduledoc """
  A database for all `TaskSystem.TaskWorker`.

  This is an agent that provides a common state between
  the different workers and a list of the different tasks
  currently being processed.
  """

  use Agent

  @doc """
  ## Examples

    iex> {:ok, pid} = TaskSystem.TaskStorage.start_link([])
    iex> is_pid(pid)
    true
  """
  @spec start_link(Agent.state()) :: Agent.on_start()
  def start_link(_), do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  @doc """
  Add data by giving it an id and the affiliate task.

  ## Examples

    iex> TaskSystem.TaskStorage.add_task(1, "unknown_task")
    {:error,  :unknown_task}

    iex> task = Task.async(fn -> 42 end)
    iex> TaskSystem.TaskStorage.add_task(1, task)
    :ok
  """
  @spec add_task(pos_integer(), Task.t()) :: :ok | {:error, :unknown_task}
  def add_task(id, %Task{} = task), do: Agent.update(__MODULE__, &Map.put(&1, id, task))
  def add_task(_id, _task), do: {:error, :unknown_task}

  @doc """
  Allows you to delete data by giving it a task id.

  ## Examples

    iex> TaskSystem.TaskStorage.remove_task(1)
    :ok

  """
  @spec remove_task(pos_integer()) :: :ok
  def remove_task(id), do: Agent.update(__MODULE__, &Map.delete(&1, id))

  @doc """
  Retrieves a list of ids affiliated with the task currently running.

  ## Examples

    iex> TaskSystem.TaskStorage.list_tasks()
    []

  """
  @spec list_tasks() :: [pos_integer()]
  def list_tasks, do: Agent.get(__MODULE__, &Map.keys/1)

  @doc """
  Retrieves a task based on an id

  ## Examples

    iex> TaskSystem.TaskStorage.get_task(1)
    nil

    iex> task = Task.async(fn -> 42 end)
    iex> TaskSystem.TaskStorage.add_task(1, task)
    iex> TaskSystem.TaskStorage.get_task(1) |> is_struct(Task)
    true
  """
  @spec get_task(pos_integer()) :: Task.t() | nil
  def get_task(id), do: Agent.get(__MODULE__, &Map.get(&1, id))

  @doc """
  Retrieves a task based on a reference

  ## Examples

    iex> task = Task.async(fn -> 42 end)
    iex> TaskSystem.TaskStorage.add_task(1, task)
    iex> {1, task} = TaskSystem.TaskStorage.get_task_by_ref(task.ref)
    iex> is_struct(task, Task)
    true
  """
  @spec get_task_by_ref(reference()) :: {pos_integer(), Task.t()} | nil
  def get_task_by_ref(ref), do: Agent.get(__MODULE__, &Enum.find(&1, fn {_, task} -> task.ref == ref end))

end
