defmodule Phx177.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      Phx177Web.Telemetry,
      # Start the Ecto repository
      Phx177.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Phx177.PubSub},
      # Start Finch
      {Finch, name: Phx177.Finch},
      # Start the Endpoint (http/https)
      Phx177Web.Endpoint
      # Start a worker by calling: Phx177.Worker.start_link(arg)
      # {Phx177.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Phx177.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Phx177Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
