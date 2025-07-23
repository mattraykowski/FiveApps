defmodule FiveAppsWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [FiveApps.Accounts, FiveApps.Campaigns],
    open_api: "/open_api"
end
