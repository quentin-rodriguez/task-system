defmodule TaskSystem.TaskSupervisorTest do
  use ExUnit.Case

  alias TaskSystem.TaskSupervisor

  setup do
    start_link_supervised!({Registry, keys: :unique, name: TaskSystem.TaskWorkerRegistry})
    :ok
  end

  test "Initialize without max_pool_size parameter no worker can start" do
    pid = start_link_supervised!(TaskSupervisor)
    assert Enum.empty?(Supervisor.which_children(pid))
    assert %{specs: 0, active: 0, supervisors: 0, workers: 0} = Supervisor.count_children(pid)
  end

  test "Initialize with parameter max_pool_size workers are active at the number passed in parameter" do
    pid = start_link_supervised!({TaskSupervisor, max_pool_size: 5})
    refute Enum.empty?(Supervisor.which_children(pid))
    assert %{specs: 5, active: 5, supervisors: 0, workers: 5} = Supervisor.count_children(pid)
  end

  test "Initialize with parameter max_pool_size but with negative value no worker are active" do
    pid = start_link_supervised!({TaskSupervisor, max_pool_size: -10})
    assert Enum.empty?(Supervisor.which_children(pid))
    assert %{specs: 0, active: 0, supervisors: 0, workers: 0} = Supervisor.count_children(pid)
  end

end
