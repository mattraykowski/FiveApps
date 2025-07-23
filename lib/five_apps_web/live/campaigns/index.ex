defmodule FiveAppsWeb.Campaigns.Index do
  use FiveAppsWeb, :live_view

  require Logger

  def mount(_params, _session, socket) do
    campaigns = FiveApps.Campaigns.list_campaigns!()

    socket =
      socket
      |> assign(:campaigns, campaigns)

    {:ok, socket}
  end

  # def render(assigns) do
  #   ~H"""

  #   """
  # end
end
