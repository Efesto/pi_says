defmodule PiSaysTest do
  use ExUnit.Case
  doctest PiSays

  test "next_word()/0" do
    words =
      0..100
      |> Enum.map(fn _ ->
        assert PiSays.next_word()
      end)

    assert :blue in words
    assert :green in words
    assert :red in words
    assert :yellow in words
  end

  describe "play/2" do
    setup do
      Application.put_env(:pi_says, :game_board, TestGameBoard)
    end

    test "play with simple sentence" do
    end
  end
end

defmodule TestGameBoard do
  def tell(sentence) do
  end

  def tell_victory() do
  end

  def tell_loss() do
  end

  def get_user_sentence() do
  end
end
