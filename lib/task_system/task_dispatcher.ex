defmodule TaskSystem.TaskDispatcher do
  use GenServer

  require Logger

  alias TaskSystem.TaskQueue

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    send(self(), :loop)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:loop, state) do
    case TaskQueue.dequeue() do
      {task_id, task} ->
        task_pid = Task.Supervisor.async_nolink(TaskSystem.TaskSupervisor, fn ->
          TaskSystem.TaskWorker.process_task(1, task)
        end)
        send(self(), :loop)

        {:ok, Map.put(state, task_pid.ref, task_id)}

      :empty ->
        Process.send_after(self(), :loop, 5)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info({ref, {:ok, worker_id, task}}, state) do
    Logger.info("It's fine !!!")

    {:noreply, Map.delete(state, ref)}
  end

  def handle_info({:DOWN, ref, :process, _pid, reason}, state) do
    Logger.error("Error reason: #{reason}")

    {:noreply, Map.delete(state, ref)}
  end

end
