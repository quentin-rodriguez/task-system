defmodule TaskSystem.TaskQueue do
  use GenServer

  @table_name :task_queue

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def enqueue(task) do
    GenServer.call(__MODULE__, {:enqueue, task})
  end

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
  def handle_call({:enqueue, task}, _from, state) do
    task_id = System.system_time(:second)
    task_data = {task_id, :erlang.term_to_binary(task)}

    :dets.insert(@table_name, task_data)

    {:reply, task_id, :queue.in(task_data, state)}
  end

  @impl true
  def handle_call(:dequeue, _from, state) do
    case :queue.out(state) do
      {{:value, {task_id, task}}, queue} ->
        {:reply, {task_id, :erlang.binary_to_term(task)}, queue}

      {:empty, queue} ->
        {:reply, :empty, queue}
    end
  end

  @impl true
  def terminate(_reason, _state) do
    :dets.close(@table_name)
  end


  defp load_from_table(table) do
    table
    |> :dets.select([{{:"$1", :"$2"}, [], [:"$2"]}])
    |> :queue.from_list()
  end


end
