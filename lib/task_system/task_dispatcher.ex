defmodule TaskSystem.TaskDispatcher do
  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def add_task(task) do
    GenServer.call(__MODULE__, {:add_task, task})
  end

  # def stop_task(task_id) do
  #   GenServer.call(__MODULE__, {:stop_task, task_id})
  # end

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:add_task, task}, from, state) do
    task_pid = Task.Supervisor.async_nolink(TaskSystem.TaskSupervisor, fn ->
      TaskSystem.TaskWorker.process_task(1, task)
    end)

    new_state = Map.put(state, task_pid.ref, from)

    {:reply, :ok, new_state}
  end

  # @impl true
  # def handle_call({:stop_task, task_id}, _from, state) do

  # end

  def handle_info(msg, state) do
    
  end

end
