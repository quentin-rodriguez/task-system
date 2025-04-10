defmodule TaskSystem.TaskQueue do
  use GenServer

  @type task() :: any()

  @table_name :task_queue

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec enqueue(any()) :: pos_integer()
  def enqueue(data) do
    GenServer.call(__MODULE__, {:enqueue, data})
  end

  @spec dequeue() :: {pos_integer(), any()} | :empty
  def dequeue do
    GenServer.call(__MODULE__, :dequeue)
  end

  @impl true
  def init(_init_arg) do
    case :dets.open_file(@table_name, type: :set) do
      {:ok, table} ->
        {:ok, load_from_table(table)}

      {:error, _reason} ->
        {:ok, :queue.new()}
    end
  end

  @impl true
  def handle_call({:enqueue, data}, _from, state) do
    task_id = System.os_time(:millisecond)

    :dets.insert(@table_name, {task_id, data})
    {:reply, task_id, :queue.in({task_id, data}, state)}
  end

  @impl true
  def handle_call(:dequeue, _from, state) do
    case :queue.out(state) do
      {{:value, value}, queue} ->
        :dets.delete_object(@table_name, value)
        {:reply, value, queue}

      {:empty, queue} ->
        {:reply, :empty, queue}
    end
  end

  @impl true
  def terminate(_reason, _state) do
    :dets.sync(@table_name)
    :dets.close(@table_name)
  end

  defp load_from_table(table) do
    table
    |> :dets.select([{{:"$1", :"$2"}, [], [{{:"$1", :"$2"}}]}])
    |> :queue.from_list()
  end


end
