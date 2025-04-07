defmodule TaskSystem.TaskDispatcher do
  use GenServer

  require Logger

  alias TaskSystem.{
    TaskWorker,
    TaskQueue
  }

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
      :empty ->
        Process.send_after(self(), :loop, 5)

      {_task_id, task} ->
        TaskWorker.process_task(1, task)
        send(self(), :loop)
    end

    {:noreply, state}
  end
  
end
