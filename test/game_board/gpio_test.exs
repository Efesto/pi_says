defmodule PiSays.GameBoard.GPIOTest do
  alias PiSays.GameBoard.GPIO
  use ExUnit.Case

  test "long_blink/1" do
    {:ok, gpio0} = Circuits.GPIO.open(0, :output)
    {:ok, gpio1} = Circuits.GPIO.open(1, :input)

    Task.async(fn -> GPIO.long_blink(gpio0) end)

    :timer.sleep(100)
    assert Circuits.GPIO.read(gpio1) == 1
    :timer.sleep(500)
    assert Circuits.GPIO.read(gpio1) == 0
  end
end
