defmodule FiveApps.Campaigns.CrewMember do
  use Ash.Resource,
    otp_app: :five_apps,
    domain: FiveApps.Campaigns,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  postgres do
    table "crew_members"
    repo FiveApps.Repo
  end

  json_api do
    type "crew_member"
  end

  actions do
    defaults [:read]

    create :create do
      accept [:name, :species, :campaign_id]
    end

    update :update do
      accept [
        :name,
        :species,
        :background,
        :motivation,
        :class,
        :gear,
        :notes,
        :reactions,
        :speed,
        :combat,
        :toughness,
        :savvy
      ]
    end

    destroy :destroy do
      accept [:id]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      public? true
      allow_nil? false
    end

    attribute :species, :string do
      public? true
      allow_nil? false
    end

    attribute :background, :string
    attribute :motivation, :string
    attribute :class, :string
    attribute :gear, :string
    attribute :notes, :string

    attribute :reactions, :integer do
      default 0
      public? true
    end

    attribute :speed, :integer do
      default 0
      public? true
    end

    attribute :combat, :integer do
      default 0
      public? true
    end

    attribute :toughness, :integer do
      default 0
      public? true
    end

    attribute :savvy, :integer do
      default 0
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :campaign, FiveApps.Campaigns.Campaign
    has_many :weapons, FiveApps.Campaigns.Weapon
  end
end
