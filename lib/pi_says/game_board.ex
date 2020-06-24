defmodule PiSays.GameBoard do
  alias Circuits.GPIO

  # Refactoring
  # Test board
  @colors_gpios [red: 3, green: 5, blue: 9, yellow: 10]
  @buttons_gpios [red: 4, green: 6, blue: 8, yellow: 7]
  @buzzer_gpio 11

  def new() do
    {:ok, buzzer_ref} = GPIO.open(@buzzer_gpio, :output)

    %{
      words:
        Enum.map(@colors_gpios, fn {name, gpio} ->
          with {:ok, led_ref} <- GPIO.open(gpio, :output),
               :ok <- GPIO.write(led_ref, 0),
               {:ok, button_ref} <- GPIO.open(@buttons_gpios[name], :input),
               :ok <- GPIO.set_interrupts(button_ref, :rising) do
            {name, %{led: %{ref: led_ref, gpio: gpio}, button: %{ref: button_ref, gpio: @buttons_gpios[name]}}}
          end
        end),
      buzzer: buzzer_ref
    }
  end

  def tell(board, []), do: board

  def tell(%{words: words} = board, [head | tail]) do
    led_ref = words[head].led.ref
    GPIO.write(led_ref, 1)
    :timer.sleep(600)
    GPIO.write(led_ref, 0)
    :timer.sleep(150)

    tell(board, tail)
  end

  def tell_victory(%{buzzer: buzzer_ref} = board) do
    GPIO.write(buzzer_ref, 1)
    :timer.sleep(300)
    GPIO.write(buzzer_ref, 0)
    :timer.sleep(300)
    GPIO.write(buzzer_ref, 1)
    :timer.sleep(300)
    GPIO.write(buzzer_ref, 0)

    board
  end

  def tell_loss(%{buzzer: buzzer_ref} = board) do
    GPIO.write(buzzer_ref, 1)
    :timer.sleep(300)
    GPIO.write(buzzer_ref, 0)
    :timer.sleep(300)
    GPIO.write(buzzer_ref, 1)
    :timer.sleep(1000)
    GPIO.write(buzzer_ref, 0)

    board
  end

  def tell_start(%{buzzer: buzzer_ref} = board) do
    GPIO.write(buzzer_ref, 1)
    :timer.sleep(200)
    GPIO.write(buzzer_ref, 0)
    :timer.sleep(100)
    GPIO.write(buzzer_ref, 1)
    :timer.sleep(200)
    GPIO.write(buzzer_ref, 0)

    board
  end

  def get_user_sentence(%{words: words} = board, sentence_length) do
    gpio_to_word =
      Enum.map(words, fn {name, %{button: %{gpio: gpio}}} ->
        {:"io_#{gpio}", name}
      end)

    read_button(gpio_to_word, board, [], sentence_length, :erlang.monotonic_time())
  end

  def read_button(gpio_to_word, %{words: words} = board, accumulator, sentence_length, threshold_timestamp) do
    if Enum.count(accumulator) == sentence_length do
      accumulator
    else
      read_values =
        receive do
          {:circuits_gpio, gpio_id, timestamp, 1} ->
            # TODO: correct this threshold offset
            if timestamp > threshold_timestamp do
              word = gpio_to_word[:"io_#{gpio_id}"]
              led_ref = words[word].led.ref
              GPIO.write(led_ref, 1)
              :timer.sleep(300)
              GPIO.write(led_ref, 0)
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
