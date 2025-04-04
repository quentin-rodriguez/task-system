defmodule TaskSystemTest do
  use ExUnit.Case
  doctest TaskSystem

  test "greets the world" do
    assert TaskSystem.hello() == :world
  end
end
