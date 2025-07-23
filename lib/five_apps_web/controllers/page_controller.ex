defmodule FiveAppsWeb.PageController do
  use FiveAppsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
