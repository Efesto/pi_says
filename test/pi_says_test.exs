defmodule PiSaysTest do
  use ExUnit.Case
  doctest PiSays

  test "greets the world" do
    assert PiSays.hello() == :world
  end
end
