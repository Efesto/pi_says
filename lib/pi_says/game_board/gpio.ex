defmodule PiSays.GameBoard.GPIO do
  alias Circuits.GPIO

  def long_blink(ref) do
    GPIO.write(ref, 1)
    :timer.sleep(600)
    GPIO.write(ref, 0)
  end
end
