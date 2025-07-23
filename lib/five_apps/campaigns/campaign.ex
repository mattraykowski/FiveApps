defmodule FiveApps.Campaigns.Campaign do
  use Ash.Resource,
    otp_app: :five_apps,
    domain: FiveApps.Campaigns,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  postgres do
    table "campaigns"
    repo FiveApps.Repo
  end

  json_api do
    type "campaign"
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:name, :description]
    end

    update :update do
      accept [:name, :description]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      public? true
      allow_nil? false
    end

    attribute :description, :string do
      public? true
      allow_nil? true
    end

    timestamps()
  end

  relationships do
    has_many :crew_members, FiveApps.Campaigns.CrewMember
    has_one :stash, FiveApps.Campaigns.Stash
    has_one :ship, FiveApps.Campaigns.Ship
  end
end
