defmodule TaskSystem.TaskApiTest do
  use ExUnit.Case, async: true
  import Plug.Test

  alias TaskSystem.{
    TaskApi,
    TaskStorage,
    TaskWorker,
    TaskQueue
  }

  @base_path "/tasks"
  @options TaskApi.init([])

  setup do
    start_link_supervised!({Registry, keys: :unique, name: TaskSystem.TaskWorkerRegistry})
    start_link_supervised!(TaskQueue)
    start_link_supervised!(TaskStorage)
    start_link_supervised!({TaskWorker, 1})
    on_exit(fn -> File.rm!("task_queue") end)
    :ok
  end

  test "Displays list of task ids" do
    conn = call(:get, @base_path)

    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body == "{\"tasks\":[]}"

    task = Task.async(fn -> 42 end)
    TaskStorage.add_task(1, task)
    conn = call(:get, @base_path)

    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body == "{\"tasks\":[1]}"
  end

  test "Create a task with the data to be processed" do
    conn = call(:post, @base_path, %{name: "Jean"})

    assert conn.status == 201
    assert conn.state == :sent
  end

  test "Delete a task by specifying id" do
    conn = call(:delete, "#{@base_path}/2")

    assert conn.status == 404
    assert conn.state == :sent
    assert conn.resp_body == "{\"message\":\"Task not found!\",\"status\":404}"

    id = TaskQueue.enqueue(%{name: "Jean"})
    Process.sleep(2000)

    conn = call(:delete, "#{@base_path}/#{id}")

    assert conn.status == 204
    assert conn.state == :sent
  end

  test "The url used does not exist" do
    conn = call(:get, "/task")

    assert conn.status == 404
    assert conn.state == :sent
    assert conn.resp_body == "{\"message\":\"Not Found!\",\"status\":404}"
  end


  defp call(method, path, body \\ nil)
  defp call(method, path, body) when is_map(body) do
    method
    |> conn(path, JSON.encode!(body))
    |> TaskApi.call(@options)
  end

  defp call(method, path, body) do
    method
    |> conn(path, body)
    |> TaskApi.call(@options)
  end


end
