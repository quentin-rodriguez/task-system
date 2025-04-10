defmodule TaskSystem.TaskStorage do
  use Agent

  @spec start_link(Agent.state()) :: Agent.on_start()
  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @spec add_task(pos_integer(), Task.t()) :: :ok
  def add_task(id, %Task{} = task) do
    Agent.update(__MODULE__, &Map.put(&1, id, task))
  end

  @spec remove_task(pos_integer()) :: :ok
  def remove_task(id) do
    Agent.update(__MODULE__, &Map.delete(&1, id))
  end

  def get_task(id) do
    Agent.get(__MODULE__, &Map.get(&1, id))
  end

  def get_task_by_ref(ref) do
    Agent.get(__MODULE__, &Enum.find(&1, fn {_, task} -> task.ref == ref end))
  end

  @spec list_tasks() :: Agent.state()
  def list_tasks do
    Agent.get(__MODULE__, &Map.keys/1)
  end

end
