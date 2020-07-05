defmodule PiSays.GameBoardTest do
  alias PiSays.GameBoard
  alias PiSays.GameBoard.GPIOConfig

  use ExUnit.Case

  test "long_blink/1" do
    {:ok, gpio0} = Circuits.GPIO.open(0, :output)
    {:ok, gpio1} = Circuits.GPIO.open(1, :input)

    Task.async(fn -> GameBoard.long_blink(gpio0) end)

    :timer.sleep(100)
    assert Circuits.GPIO.read(gpio1) == 1
    :timer.sleep(500)
    assert Circuits.GPIO.read(gpio1) == 0
  end

  test "button_gpio_to_word/2" do
    config = %GPIOConfig{
      words: [
        panda: %{button: %{ref: nil, gpio: 666}}
      ]
    }

    assert :panda == GameBoard.button_gpio_to_word(config, 666)
  end
end
