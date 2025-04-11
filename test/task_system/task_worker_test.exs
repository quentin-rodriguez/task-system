defmodule TaskSystem.TaskWorkerTest do
  use ExUnit.Case

  alias TaskSystem.{
    TaskWorker,
    TaskManager,
    TaskStorage,
    TaskQueue
  }

  setup do
    start_link_supervised!({Registry, keys: :unique, name: TaskSystem.TaskWorkerRegistry})
    start_link_supervised!(TaskStorage)
    start_link_supervised!(TaskQueue)
    on_exit(fn -> File.rm!("task_queue") end)
    :ok
  end

  test "ddd" do
    id = TaskQueue.enqueue(:task_one)
    pid = start_link_supervised!({TaskWorker, 1})
    :erlang.trace(pid, true, [:receive])

    assert_receive {:trace, ^pid, :receive, :loop}
    assert %Task{ref: task_ref, pid: task_pid} = TaskStorage.get_task(id)

    assert :ok = TaskManager.stop_task(id)
    refute TaskStorage.get_task(id)
    assert :empty = TaskQueue.dequeue()
  end

  test "Data processing by a single worker" do
    task_id = TaskQueue.enqueue(:task_one)
    pid = start_link_supervised!({TaskWorker, 1})
    :erlang.trace(pid, true, [:receive])

    assert_receive {:trace, ^pid, :receive, :loop}
    assert %Task{ref: task_ref} = TaskStorage.get_task(task_id)

    assert_receive {:trace, ^pid, :receive, {^task_ref, {:ok, ^task_id, :task_one}}}, 7000
    assert :empty = TaskQueue.dequeue()
  end

  test "Multiple data processing by multiple workers" do
    id1 = TaskQueue.enqueue(:task_one)
    id2 = TaskQueue.enqueue(:task_two)

    pid1 = start_link_supervised!({TaskWorker, 1})
    :erlang.trace(pid1, true, [:receive])

    pid2 = start_link_supervised!({TaskWorker, 2})
    :erlang.trace(pid2, true, [:receive])

    assert_receive {:trace, ^pid1, :receive, :loop}
    assert %Task{ref: ref1} = TaskStorage.get_task(id1)

    assert_receive {:trace, ^pid2, :receive, :loop}
    assert %Task{ref: ref2} = TaskStorage.get_task(id2)

    assert_receive {:trace, ^pid1, :receive, {^ref1, {:ok, ^id1, :task_one}}}, 7000
    refute TaskStorage.get_task(id1)

    assert_receive {:trace, ^pid2, :receive, {^ref2, {:ok, ^id2, :task_two}}}, 7000
    refute TaskStorage.get_task(id2)

    assert :empty = TaskQueue.dequeue()
  end

end
