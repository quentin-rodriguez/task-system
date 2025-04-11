defmodule TaskSystem.TaskApi do
  @moduledoc """
  This plug allows interaction with the business logic of the `task_system` project
  by providing an API which is available from the url **http://localhost:4000/tasks**.

  It provides 3 endpoints with the following methods:

  **POST**: To create a new task to be put in `TaskSystem.TaskQueue`

  ```bash
  curl -X POST http://localhost:4000/tasks -d '{"name": "Jean", "number": "42"}'
  ```

  **GET**: To get a list of running tasks

  ```bash
  curl -X GET http://localhost:4000/tasks
  ```

  **DELETE**: To stop a running task

  ```bash
  curl -X DELETE http://localhost:4000/tasks/:id
  ```
  """

  import Plug.Conn

  @spec init(Keyword.t()) :: Keyword.t()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def call(%Plug.Conn{method: "GET", path_info: ["tasks"]} = conn, _opts) do
    json(conn, :ok, %{
      tasks: TaskSystem.list_tasks()
    })
  end

  def call(%Plug.Conn{method: "POST", path_info: ["tasks"]} = conn, opts) do
    case Plug.Conn.read_body(conn, opts) do
      {:ok, body, _conn} ->
        data = JSON.decode!(body)

        json(conn, :created, %{
          id: TaskSystem.add_task(data),
          data: data
        })

      {:error, reason} ->
        json(conn, :bad_request, %{
          status: 400,
          message: reason
        })
    end
  end

  def call(%Plug.Conn{method: "DELETE", path_info: ["tasks", id]} = conn, _opts) do
    task_id = String.to_integer(id)


    case TaskSystem.stop_task(task_id) do
      :ok ->
        send_resp(conn, :no_content, "")

      {:error, :not_found} ->
        json(conn, :not_found, %{
          status: 404,
          message: "Task not found!"
        })
    end

  end

  def call(%Plug.Conn{} = conn, _opts) do
    json(conn, :not_found, %{
      status: 404,
      message: "Not Found!"
    })
  end

  defp json(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, JSON.encode!(body))
  end


end
