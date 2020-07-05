defmodule PiSays.GameWorker do
  def start_link(arg) do
    pid = spawn_link(__MODULE__, :play, arg)
    {:ok, pid}
  end

  def play(_arg) do
    PiSays.GameBoard.GPIOConfig.new()
    |> PiSays.play()
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
end
