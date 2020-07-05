defmodule PiSays.GameBoard do
  alias Circuits.GPIO
  alias PiSays.GameBoard.GPIOConfig

  def tell(%GPIOConfig{} = config, []), do: config

  def tell(%GPIOConfig{words: words} = config, [head | tail]) do
    led_ref = words[head].led.ref
    long_blink(led_ref)
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

  def get_user_sentence(%GPIOConfig{} = config, sentence_length) do
    read_button(config, [], sentence_length, :erlang.monotonic_time())
  end

  def read_button(
        %GPIOConfig{words: words} = config,
        user_sentence,
        sentence_length,
        threshold_timestamp
      ) do
    if Enum.count(user_sentence) == sentence_length do
      user_sentence
    else
      user_word =
        receive do
          {:circuits_gpio, gpio, timestamp, 1} ->
            # TODO: correct this threshold offset
            # https://github.com/elixir-circuits/circuits_gpio/issues/3
            if timestamp > threshold_timestamp do
              word = button_gpio_to_word(config, gpio)
              led_ref = words[word].led.ref
              long_blink(led_ref)
              [word]
            else
              []
            end
        after
          5000 ->
            [:missed]
        end

      read_button(
        config,
        user_sentence ++ user_word,
        sentence_length,
        threshold_timestamp
      )
    end
  end

  def long_blink(ref) do
    GPIO.write(ref, 1)
    :timer.sleep(600)
    GPIO.write(ref, 0)
  end

  def button_gpio_to_word(%GPIOConfig{words: words}, gpio) do
    {word, %{}} =
      words
      |> Enum.find(fn {_, %{button: %{gpio: wgpio}}} -> gpio == wgpio end)

    word
  end
end
