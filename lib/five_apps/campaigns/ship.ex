defmodule FiveApps.Campaigns.Ship do
  use Ash.Resource,
    otp_app: :five_apps,
    domain: FiveApps.Campaigns,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  postgres do
    table "ships"
    repo FiveApps.Repo
  end

  json_api do
    type "ship"
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:name, :campaign_id]
      primary? true
    end

    update :update do
      accept [:name, :hull, :debt, :traits, :upgrades, :story_tracks, :event, :clock, :rumors]
      primary? true
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      public? true
      allow_nil? true
    end

    attribute :hull, :integer do
      public? true
      default 0
    end

    attribute :debt, :integer do
      public? true
      default 0
    end

    attribute :traits, :string
    attribute :upgrades, :string
    attribute :story_tracks, :string

    attribute :event, :integer do
      public? true
      default 0
    end

    attribute :clock, :integer do
      public? true
      default 0
    end

    attribute :rumors, :string do
      public? true
    end

    attribute :campaign_id, :uuid

    timestamps()
  end

  relationships do
    belongs_to :campaign, FiveApps.Campaigns.Campaign
  end
end
