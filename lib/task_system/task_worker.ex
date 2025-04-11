defmodule TaskSystem.TaskWorker do
  @moduledoc """
  This is a worker for `TaskSystem.TaskQueue`.

  Workers are responsible for interacting with `TaskSystem.TaskQueue`.
  It automatically retrieves data from the queue and processes it immediately afterwards.
  Data processing is handled by an asynchronous task.

  Note that you can start a worker manually, but I recommend using `TaskSystem.TaskSupervisor`
  to manage a pool of workers to take advantage of concurrency to retrieve and process data.
  """

  use GenServer

  require Logger

  alias TaskSystem.{
    TaskQueue,
    TaskStorage
  }

  # 1 second in milliseconds
  @next_interval :timer.seconds(1)

  @doc """
  Starts the `#{__MODULE__}` GenServer

  At initialization time, a repeating task is launched
  to retrieve data from the `TaskSystem.TaskQueue`.

  ## Examples

    iex> {:ok, pid} = TaskSystem.TaskWorker.start_link(1)
    iex> is_pid(pid)
    true
  """
  @spec start_link(pos_integer()) :: GenServer.on_start()
  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: via_tuple(id))
  end

  @doc """
  These are the GenServer specifications `#{__MODULE__}`.
  """
  @spec child_spec(pos_integer()) :: Supervisor.child_spec()
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
    Logger.info("Worker #{id} is started!")
    {:ok, %{id: id}}
  end

  @impl true
  def handle_info(:loop, state) do
    case TaskQueue.dequeue() do
      :empty ->
        # TaskQueue is empty, check again in 1 second
        # to avoid spamming it with useless deque requests
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
    Process.demonitor(ref, [:flush])

    case TaskStorage.get_task(task_id) do
      %Task{} ->
        Logger.info("Task #{task_id} has just been completed with the following content: #{inspect(data)}")
        TaskStorage.remove_task(task_id)

      nil ->
        Logger.info("Task #{task_id} has just been stopped with the reference #{inspect(ref)}")
        :ok
    end

    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, :normal}, state) do
    case TaskStorage.get_task_by_ref(ref) do
      {task_id, %Task{}} ->
        Logger.info("Task #{task_id} has just been stopped with the reference #{inspect(ref)}")
        TaskStorage.remove_task(task_id)

      nil ->
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
