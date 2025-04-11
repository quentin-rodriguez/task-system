defmodule TaskSystem.TaskStorageTest do
  use ExUnit.Case

  alias TaskSystem.TaskStorage

  setup do
    start_link_supervised!(TaskStorage)
    {:ok, %{task: Task.async(fn -> 42 end)}}
  end

  test "Adding a task to storage", %{task: task} do
    assert {:error, :unknown_task} = TaskStorage.add_task(1, "Test")
    refute TaskStorage.get_task(1)
    assert :ok = TaskStorage.add_task(2, task)
    assert %Task{} = TaskStorage.get_task(2)
  end

  test "Deleting a task from storage", %{task: task} do
    assert :ok = TaskStorage.add_task(1, task)
    assert %Task{} = TaskStorage.get_task(1)
    assert :ok = TaskStorage.remove_task(1)
    refute TaskStorage.get_task(1)
  end

  test "List of tasks in storage", %{task: task} do
    assert [] = TaskStorage.list_tasks()

    Enum.each([1, 2, 3, 4], &TaskStorage.add_task(&1, task))
    assert [1, 2, 3, 4] = TaskStorage.list_tasks()

    Enum.each([2, 3], &TaskStorage.remove_task/1)
    assert [1, 4] = TaskStorage.list_tasks()
  end

  test "Retrieving information from the task using its reference", %{task: task} do
    assert :ok = TaskStorage.add_task(1, task)
    assert {1, %Task{}} = TaskStorage.get_task_by_ref(task.ref)
    assert :ok = TaskStorage.remove_task(1)
    refute TaskStorage.get_task_by_ref(task.ref)
  end

end
