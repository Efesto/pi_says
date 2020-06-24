defmodule PiSays.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PiSays.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: PiSays.Worker.start_link(arg)
        # {PiSays.Worker, arg},
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      {PiSays.Worker, []}
    ]
  end

  def children(_target) do
    [
      {PiSays.Worker, []}
    ]
  end

  def target() do
    Application.get_env(:pi_says, :target)
  end
end
