defmodule TaskSystem.TaskWorker do
  use GenServer

  require Logger

  defstruct [
    :id,
    tasks_processed: 0,
    tasks_completed: 0,
    tasks_failed: 0
  ]


  @spec start_link(String.t()) :: GenServer.on_start()
  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: via_tuple(id))
  end

  def process_task(id, task) do
    GenServer.call(via_tuple(id), {:process_task, task})
  end

  def get_tasks_completed(id) do
    GenServer.call(via_tuple(id), :get_tasks_completed)
  end

  @impl true
  def init(id) do
    {:ok, %__MODULE__{id: id}}
  end

  @impl true
  def handle_call({:process_task, task}, _from, state) do
    processing_time = Enum.random(1..5) |> :timer.seconds()
    Process.sleep(processing_time)

    new_state = %__MODULE__{state |
      tasks_processed: state.tasks_processed + 1
    }

    {:reply, {:ok, state.id, task}, new_state}
  end

  @impl true
  def handle_call(:get_tasks_completed, _from, state) do
    {:reply, state.tasks_completed, state}
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
