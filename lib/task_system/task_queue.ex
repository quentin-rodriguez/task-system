defmodule TaskSystem.TaskQueue do
  @moduledoc """
  It's a simple queue, when we want to add a task, it will be put on hold in the queue before it is taken care of by a worker.

  ## Persistence

  TaskQueue supports data persistence to make it more durable.
  To start data persistence, simply call the `start_link/1` function e.g.

    {:ok, pid} = #{__MODULE__}.start_link([])

  ## Usage

  To use TaskQueue, simply use the functions `enqueue/1` and `dequeue/0`.
  For the rest, everything is handled automatically: queue polling, error handling, task processing times, restarting downtime workers.
  """

  use GenServer

  @type task() :: any()

  @table_name String.to_charlist("tmp/task_queue.dat")

  @doc """
  Starts the TaskQueue GenServer.

  At initialization time, it retrieves the data contained in the "#{@table_name}" file to fill the queue.
  If the file does not exist, it will automatically create it and the queue will be empty.

  ## Examples

    iex> {:ok, pid} = TaskSystem.TaskQueue.start_link([])
    iex> is_pid(pid)
    true
  """
  @spec start_link(any()) :: GenServer.on_start()
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @doc """
  Inserts a value into the queue, returning an integer id.

  ## Examples

    iex> id = TaskSystem.TaskQueue.enqueue(:task_one)
    iex> is_integer(id)
    true
  """
  @spec enqueue(any()) :: pos_integer()
  def enqueue(data), do: GenServer.call(__MODULE__, {:enqueue, data})

  @doc """
  Retrieves the first value entered in the queue.
  If there is no value, a :empty value is returned.

  ## Examples

    iex> TaskSystem.TaskQueue.enqueue(:task_one)
    iex> TaskSystem.TaskQueue.dequeue()
    :task_one
  """
  @spec dequeue() :: {pos_integer(), any()} | :empty
  def dequeue, do: GenServer.call(__MODULE__, :dequeue)

  @impl true
  def init(_init_arg) do
    File.mkdir_p("tmp/")

    case :dets.open_file(@table_name, type: :set) do
      {:ok, table} ->
        {:ok, load_from_table(table)}

      {:error, _reason} ->
        {:ok, :queue.new()}
    end
  end

  @impl true
  def handle_call({:enqueue, data}, _from, state) do
    task_id = System.os_time()

    :dets.insert(@table_name, {task_id, data})
    {:reply, task_id, :queue.in({task_id, data}, state)}
  end

  @impl true
  def handle_call(:dequeue, _from, state) do
    case :queue.out(state) do
      {{:value, {id, _} = value}, queue} ->
        :dets.delete(@table_name, id)
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
    |> Enum.sort_by(fn {id, _} -> id end)
    |> :queue.from_list()
  end


end
