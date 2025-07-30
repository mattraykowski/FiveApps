defmodule FiveAppsWeb.Home.Index do
  use FiveAppsWeb, :live_view

  require Logger

  on_mount {FiveAppsWeb.LiveUserAuth, :live_user_optional}

  def mount(_params, _session, socket) do
    # Initialize any data needed for the home page
    if socket.assigns.current_user != nil do
      {:ok, redirect(socket, to: ~p"/campaigns")}
    else
      {:ok, socket}
    end
  end
end
