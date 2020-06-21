defmodule PiSays.GameBoard do
  alias Circuits.GPIO

  # TODO: Why yellow doesn't work?

  # Refactoring
  # Test board
  @colors_gpios [red: 3, green: 5, blue: 7]
  @buzzer_gpio 11

  def new() do
    {:ok, buzzer_ref} = GPIO.open(@buzzer_gpio, :output)

    %{
      words:
        Enum.map(@colors_gpios, fn {name, gpio} ->
          with {:ok, led_ref} <- GPIO.open(gpio, :output),
               :ok <- GPIO.write(led_ref, 0),
               {:ok, button_ref} <- GPIO.open(gpio + 1, :input),
               :ok <- GPIO.set_interrupts(button_ref, :rising) do
            {name, %{led: led_ref, button: %{ref: button_ref, gpio: gpio + 1}}}
          end
        end),
      buzzer: buzzer_ref
    }
  end

  def tell(board, []), do: board

  def tell(board, [head | tail]) do
    led = board.words[head].led
    GPIO.write(led, 1)
    :timer.sleep(600)
    GPIO.write(led, 0)
    :timer.sleep(150)

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
    :timer.sleep(1000)
    GPIO.write(buzzer_ref, 0)

    :ok
  end

  def get_user_sentence(board, sentence_length) do
    gpio_to_word =
      Enum.map(board.words, fn {name, %{button: %{gpio: gpio}}} ->
        {:"io_#{gpio}", name}
      end)

    read_button(gpio_to_word, board, [], sentence_length, :erlang.monotonic_time())
  end

  def read_button(gpio_to_word, board, accumulator, sentence_length, threshold_timestamp) do
    if Enum.count(accumulator) == sentence_length do
      accumulator
    else
      read_values =
        receive do
          {:circuits_gpio, gpio_id, timestamp, 1} ->
            # TODO: correct this threshold offset
            if timestamp > threshold_timestamp do
              word = gpio_to_word[:"io_#{gpio_id}"]
              led = board.words[word].led
              GPIO.write(led, 1)
              :timer.sleep(300)
              GPIO.write(led, 0)
              [word]
            else
              []
            end
        after
          5000 ->
            [:missed]
        end

      read_button(
        gpio_to_word,
        board,
        accumulator ++ read_values,
        sentence_length,
        threshold_timestamp
      )
    end
  end
end
