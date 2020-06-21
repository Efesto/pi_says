defmodule PiSays.Worker do
  @game_board Application.fetch_env!(:pi_says, :game_board)

  def start_link(arg) do
    pid = spawn_link(__MODULE__, :play, arg)
    {:ok, pid}
  end

  def play(_arg) do
    @game_board.new
    |> PiSays.play()
  end
end
