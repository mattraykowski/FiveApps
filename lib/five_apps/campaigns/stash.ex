defmodule FiveApps.Campaigns.Stash do
  use Ash.Resource,
    otp_app: :five_apps,
    domain: FiveApps.Campaigns,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  postgres do
    table "stashes"
    repo FiveApps.Repo
  end

  json_api do
    type "stash"
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:notes, :credits, :patrons, :rivals, :campaign_id]
      primary? true
    end

    update :update do
      accept [:notes, :credits, :patrons, :rivals]
      primary? true
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :notes, :string

    attribute :credits, :integer do
      default 0
    end

    attribute :patrons, :integer do
      default 0
    end

    attribute :rivals, :integer do
      default 0
    end

    attribute :campaign_id, :uuid

    timestamps()
  end

  relationships do
    belongs_to :campaign, FiveApps.Campaigns.Campaign
  end
end
