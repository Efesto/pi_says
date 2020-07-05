defmodule PiSays.GameBoard.GPIOConfig do
  alias Circuits.GPIO

  defstruct words: [], buzzer: nil

  @colors_gpios [red: 3, green: 5, blue: 9, yellow: 10]
  @buttons_gpios [red: 4, green: 6, blue: 8, yellow: 7]
  @buzzer_gpio 11

  def new() do
    {:ok, buzzer_ref} = GPIO.open(@buzzer_gpio, :output)

    %PiSays.GameBoard.GPIOConfig{
      words:
        Enum.map(@colors_gpios, fn {name, gpio} ->
          with {:ok, led_ref} <- GPIO.open(gpio, :output),
               :ok <- GPIO.write(led_ref, 0),
               {:ok, button_ref} <- GPIO.open(@buttons_gpios[name], :input),
               :ok <- GPIO.set_interrupts(button_ref, :rising) do
            {name,
             %{
               led: %{ref: led_ref, gpio: gpio},
               button: %{ref: button_ref, gpio: @buttons_gpios[name]}
             }}
          end
        end),
      buzzer: buzzer_ref
    }
  end
end
