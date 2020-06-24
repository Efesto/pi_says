defmodule PiSays do
  @game_board Application.fetch_env!(:pi_says, :game_board)

  def play(board) do
    play(board, [next_word()])
  end

  def play(board, sentence) do
    user_sentence =
      board
      |> @game_board.tell(sentence)
      |> @game_board.get_user_sentence(Enum.count(sentence))

    if user_sentence == sentence do
      @game_board.tell_victory(board)
      play(board, expand_sentence(sentence))
    else
      @game_board.tell_loss(board)
      play(board, [])
    end

    :timer.sleep(5000)
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
