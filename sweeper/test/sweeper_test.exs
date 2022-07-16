defmodule SweeperTest do
  use ExUnit.Case
  doctest Sweeper

  test "greets the world" do
    assert Sweeper.hello() == :world
  end
end
