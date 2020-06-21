defmodule PiSays.GameBoard do
  alias Circuits.GPIO

  @colors_gpios [red: 3, green: 5, blue: 7, yellow: 9]
  @buzzer_gpio 11

  def new() do
    {:ok, buzzer_ref} = GPIO.open(@buzzer_gpio, :output)

    %{
      words:
        Enum.map(@colors_gpios, fn {name, gpio} ->
          {:ok, led_ref} = GPIO.open(gpio, :output)
          {:ok, button_ref} = GPIO.open(gpio + 1, :output)
          {name, %{led: led_ref, button: button_ref}}
        end),
      buzzer: buzzer_ref
    }
  end

  def tell(_board, []), do: :ok

  def tell(board, [head | tail]) do
    led = board.words[head].led
    GPIO.write(led, 1)
    :timer.sleep(1000)
    GPIO.write(led, 0)

    tell(board, tail)
  end

  def tell_victory(board) do
    buzzer_ref = board.buzzer

    GPIO.write(buzzer_ref, 1)
    :timer.sleep(300)
    GPIO.write(buzzer_ref, 0)
    :timer.sleep(300)
    GPIO.write(buzzer_ref, 1)
    :timer.sleep(300)
    GPIO.write(buzzer_ref, 0)

    :ok
  end

  def tell_loss(board) do
    buzzer_ref = board.buzzer

    GPIO.write(buzzer_ref, 1)
    :timer.sleep(300)
    GPIO.write(buzzer_ref, 0)
    :timer.sleep(300)
    GPIO.write(buzzer_ref, 1)
    :timer.sleep(2000)
    GPIO.write(buzzer_ref, 0)

    :ok
  end

  def get_user_sentence(_board) do
    [:red, :green, :blue, :yellow]
  end
end
