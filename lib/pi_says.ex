defmodule PiSays do
  alias PiSays.GameBoard.GPIOConfig
  alias PiSays.GameBoard

  @round_interval 5000

  def play(%GPIOConfig{} = board_config) do
    GameBoard.tell_start(board_config)
    |> play([next_word()])
  end

  def play(%GPIOConfig{} = board_config, sentence) do
    user_sentence =
      board_config
      |> GameBoard.tell(sentence)
      |> GameBoard.get_user_sentence(Enum.count(sentence))

    if user_sentence == sentence do
      board_config
      |> GameBoard.tell_victory()
      |> play(expand_sentence(sentence))
    else
      board_config
      |> GameBoard.tell_loss()
      |> play([])
    end

    :timer.sleep(@round_interval)
  end

  defp expand_sentence(sentence) do
    sentence ++ [next_word()]
  end

  def next_word() do
    :random.seed(:erlang.now())

    [:blue, :red, :green, :yellow]
    |> Enum.random()
  end
end
