defmodule TaskSystem.TaskWorker do
  use GenServer

  require Logger

  @type worker_id() :: pos_integer()

  defstruct [
    :id,
    tasks_processed: 0,
    tasks_completed: 0,
  ]


  @spec start_link(worker_id()) :: GenServer.on_start()
  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: via_tuple(id))
  end

  @spec process_task(worker_id(), any()) :: {:ok, worker_id(), reference()}
  def process_task(id, task) do
    GenServer.call(via_tuple(id), {:process_task, task})
  end

  @spec get_tasks_processed(worker_id()) :: pos_integer()
  def get_tasks_processed(id) do
    GenServer.call(via_tuple(id), :get_tasks_processed)
  end

  @spec get_tasks_completed(worker_id()) :: pos_integer()
  def get_tasks_completed(id) do
    GenServer.call(via_tuple(id), :get_tasks_completed)
  end

  @impl true
  def init(id) do
    {:ok, %__MODULE__{id: id}}
  end

  @impl true
  def handle_call(:get_tasks_processed, _from, state) do
    {:reply, state.tasks_processed, state}
  end

  @impl true
  def handle_call(:get_tasks_completed, _from, state) do
    {:reply, state.tasks_completed, state}
  end

  @impl true
  def handle_call({:process_task, task}, _from, state) do
    task_pid = Task.Supervisor.async_nolink(TaskSystem.TaskSupervisor, fn ->
      1..5
      |> Enum.random()
      |> :timer.seconds()
      |> Process.sleep()
    end)

    new_state = %__MODULE__{state |
        tasks_processed: state.tasks_processed + 1
      }

    {:reply, {:ok, state.id, task_pid.ref}, new_state}
  end

  @impl true
  def handle_info({ref, :ok}, state) do
    Process.demonitor(ref, [:flush])

    Logger.info("It's fine !!!")

    new_state = %__MODULE__{state |
        tasks_completed: state.tasks_completed + 1,
        tasks_processed: state.tasks_processed - 1
      }

    {:noreply, new_state}
  end

  @impl true
  def handle_info(_msg, state) do
    Logger.error("Down message")
    {:noreply, state}
  end

  def child_spec(id) do
    %{
      id: {__MODULE__, id},
      start: {__MODULE__, :start_link, [id]},
      restart: :permanent,
      type: :worker
    }
  end

  defp via_tuple(id) do
    {:via, Registry, {TaskSystem.TaskWorkerRegistry, id}}
  end

end
