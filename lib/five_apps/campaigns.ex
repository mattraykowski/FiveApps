defmodule FiveApps.Campaigns do
  use Ash.Domain,
    otp_app: :five_apps,
    extensions: [AshAdmin.Domain, AshPhoenix.Domain, AshJsonApi.Domain]

  admin do
    show? true
  end

  json_api do
    routes do
      base_route "/campaigns", FiveApps.Campaigns.Campaign do
        post :create, route: "/"
        get :read, route: "/"
      end
    end
  end

  resources do
    resource FiveApps.Campaigns.Campaign do
      define :list_campaigns, action: :read
      define :get_campaign, action: :read, get_by: [:id]
    end

    resource FiveApps.Campaigns.CrewMember
    resource FiveApps.Campaigns.Stash
    resource FiveApps.Campaigns.Ship
    resource FiveApps.Campaigns.Weapon
  end
end
