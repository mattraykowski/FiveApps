defmodule FiveApps.Campaigns.Weapon do
  use Ash.Resource,
    otp_app: :five_apps,
    domain: FiveApps.Campaigns,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  postgres do
    table "weapons"
    repo FiveApps.Repo
  end

  json_api do
    type "weapon"
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:name, :range, :shot, :damage, :traits, :crew_member_id]
    end

    update :update do
      accept [:name, :range, :shot, :damage, :traits]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      public? true
      allow_nil? false
    end

    attribute :range, :string do
      public? true
    end

    attribute :shot, :integer do
      public? true
      default 0
    end

    attribute :damage, :integer do
      public? true
      default 0
    end

    attribute :traits, :string do
      public? true
      allow_nil? true
    end

    timestamps()
  end

  relationships do
    belongs_to :crew_member, FiveApps.Campaigns.CrewMember
  end
end
