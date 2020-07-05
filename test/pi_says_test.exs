defmodule PiSaysTest do
  use ExUnit.Case
  doctest PiSays

  test "next_word()/0 returns all words eventually" do
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
end
