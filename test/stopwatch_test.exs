defmodule StopwatchTest do
  use ExUnit.Case
  doctest Stopwatch

  test "greets the world" do
    assert Stopwatch.hello() == :world
  end
end
