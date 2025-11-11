defmodule FiveApps.Campaigns do
  use Ash.Domain,
    otp_app: :five_apps,
    extensions: [AshAdmin.Domain, AshPhoenix, AshJsonApi.Domain]

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
      define :create_campaign, action: :create
      define :update_campaign, action: :update
      define :delete_campaign, action: :destroy
    end

    resource FiveApps.Campaigns.CrewMember do
      define :create_crew_member, action: :create
      define :get_crew_member, action: :read, get_by: [:id]
      define :update_crew_member, action: :update
      define :set_crew_member_leader, action: :set_leader
      define :delete_crew_member, action: :destroy
    end

    resource FiveApps.Campaigns.Stash
    resource FiveApps.Campaigns.Ship

    resource FiveApps.Campaigns.Weapon do
      define :create_weapon, action: :create
      define :update_weapon, action: :update
      define :delete_weapon, action: :destroy
    end
  end
end
