defmodule TaskSystem.TaskQueueTest do
  use ExUnit.Case

  alias TaskSystem.TaskQueue

  setup do
    on_exit(fn -> File.rm!("tmp/task_queue.dat") end)
    {:ok, %{pid: start_link_supervised!(TaskQueue)}}
  end

  test "Returns :empty on initialization" do
    assert :empty = TaskQueue.dequeue()
  end

  test "Returns :empty if all other values are processed" do
    task_id = TaskQueue.enqueue(:first_test)

    assert {^task_id, :first_test} = TaskQueue.dequeue()
    assert :empty = TaskQueue.dequeue()
  end

  test "Returns values in the same FIFO order" do
    first_task_id = TaskQueue.enqueue(:first_test)
    second_task_id = TaskQueue.enqueue(:second_test)

    assert {^first_task_id, :first_test} = TaskQueue.dequeue()
    assert {^second_task_id, :second_test} = TaskQueue.dequeue()
  end

  test "Queue has been restored from the dets", %{pid: pid} do
    first_id = TaskQueue.enqueue(:task_one)
    second_id = TaskQueue.enqueue(:task_two)

    Process.flag(:trap_exit, true)
    Process.exit(pid, :stop)
    refute Process.alive?(pid)
    Process.flag(:trap_exit, false)

    TaskQueue.start_link([])
    assert {^first_id, :task_one} = TaskQueue.dequeue()
    assert {^second_id, :task_two} = TaskQueue.dequeue()
  end

end
