defmodule PiSays.GameBoard do
  alias Circuits.GPIO
  alias PiSays.GameBoard.GPIO, as: BoardGPIO
  alias PiSays.GameBoard.GPIOConfig

  def tell(%GPIOConfig{} = config, []), do: config

  def tell(%GPIOConfig{words: words} = config, [head | tail]) do
    led_ref = words[head].led.ref
    BoardGPIO.long_blink(led_ref)
    :timer.sleep(150)

    tell(config, tail)
  end

  def tell_victory(%GPIOConfig{buzzer: buzzer_ref} = config) do
    GPIO.write(buzzer_ref, 1)
    :timer.sleep(300)
    GPIO.write(buzzer_ref, 0)
    :timer.sleep(300)
    GPIO.write(buzzer_ref, 1)
    :timer.sleep(300)
    GPIO.write(buzzer_ref, 0)

    config
  end

  def tell_loss(%GPIOConfig{buzzer: buzzer_ref} = config) do
    GPIO.write(buzzer_ref, 1)
    :timer.sleep(300)
    GPIO.write(buzzer_ref, 0)
    :timer.sleep(300)
    GPIO.write(buzzer_ref, 1)
    :timer.sleep(1000)
    GPIO.write(buzzer_ref, 0)

    config
  end

  def tell_start(%GPIOConfig{buzzer: buzzer_ref} = config) do
    GPIO.write(buzzer_ref, 1)
    :timer.sleep(200)
    GPIO.write(buzzer_ref, 0)
    :timer.sleep(100)
    GPIO.write(buzzer_ref, 1)
    :timer.sleep(200)
    GPIO.write(buzzer_ref, 0)

    config
  end

  def get_user_sentence(%GPIOConfig{words: words} = config, sentence_length) do
    gpio_to_word =
      Enum.map(words, fn {name, %{button: %{gpio: gpio}}} ->
        {:"io_#{gpio}", name}
      end)

    read_button(gpio_to_word, config, [], sentence_length, :erlang.monotonic_time())
  end

  def read_button(
        gpio_to_word,
        %GPIOConfig{words: words} = config,
        accumulator,
        sentence_length,
        threshold_timestamp
      ) do
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
              BoardGPIO.long_blink(led_ref)
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
        config,
        accumulator ++ read_values,
        sentence_length,
        threshold_timestamp
      )
    end
  end
end
