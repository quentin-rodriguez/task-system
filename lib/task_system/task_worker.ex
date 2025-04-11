defmodule TaskSystem.TaskWorker do
  use GenServer

  alias TaskSystem.{
    TaskQueue,
    TaskStorage
  }

  require Logger

  @type worker_id() :: pos_integer()

  @next_interval :timer.seconds(1)

  @spec start_link(worker_id()) :: GenServer.on_start()
  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: via_tuple(id))
  end

  @spec child_spec(worker_id()) :: Supervisor.child_spec()
  def child_spec(id) do
    %{
      id: {__MODULE__, id},
      start: {__MODULE__, :start_link, [id]},
      restart: :permanent,
      type: :worker
    }
  end

  @impl true
  def init(id) do
    schedule_loop()
    {:ok, %{id: id}}
  end

  @impl true
  def handle_info(:loop, state) do
    case TaskQueue.dequeue() do
      :empty ->
        schedule_loop(@next_interval)

      {task_id, data} ->
        task = process_task(task_id, data)
        TaskStorage.add_task(task_id, task)
        schedule_loop()
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({ref, {:ok, task_id, data}}, state) do
    TaskStorage.remove_task(task_id)
    Process.demonitor(ref, [:flush])

    Logger.info("Task #{task_id} has just been completed with the following content: #{inspect(data)}")

    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    case TaskStorage.get_task_by_ref(ref) do
      {task_id, %Task{}} ->
        Logger.warning("Task #{task_id} received DOWN message for reference #{inspect(ref)}")
        TaskStorage.remove_task(task_id)

      _ ->
        :ok
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(_msg, state), do: {:noreply, state}

  defp process_task(task_id, data) do
    Task.async(fn ->
      processing_time =
        1..5
        |> Enum.random()
        |> :timer.seconds()

      Process.sleep(processing_time)

      {:ok, task_id, data}
    end)
  end

  defp schedule_loop(interval \\ nil)
  defp schedule_loop(interval) when is_integer(interval), do: Process.send_after(self(), :loop, interval)
  defp schedule_loop(_interval), do: send(self(), :loop)

  defp via_tuple(id), do: {:via, Registry, {TaskSystem.TaskWorkerRegistry, id}}

end
