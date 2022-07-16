defmodule Sweeperui.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SweeperuiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Sweeperui.PubSub},
      # Start the Endpoint (http/https)
      SweeperuiWeb.Endpoint
      # Start a worker by calling: Sweeperui.Worker.start_link(arg)
      # {Sweeperui.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sweeperui.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SweeperuiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
