defmodule PiSays.Worker do
  @game_board Application.fetch_env!(:pi_says, :game_board)

  def start_link(_arg) do
    pid = spawn_link(__MODULE__, :play, [])
    {:ok, pid}
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def play() do
    @game_board.new
    |> PiSays.play()
  end
end
