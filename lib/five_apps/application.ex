defmodule FiveApps.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FiveAppsWeb.Telemetry,
      FiveApps.Repo,
      {DNSCluster, query: Application.get_env(:five_apps, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FiveApps.PubSub},
      # Start a worker by calling: FiveApps.Worker.start_link(arg)
      # {FiveApps.Worker, arg},
      # Start to serve requests, typically the last entry
      FiveAppsWeb.Endpoint,
      {Absinthe.Subscription, FiveAppsWeb.Endpoint},
      AshGraphql.Subscription.Batcher,
      {AshAuthentication.Supervisor, [otp_app: :five_apps]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FiveApps.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FiveAppsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
