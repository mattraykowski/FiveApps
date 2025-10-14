defmodule FiveApps.Campaigns.Campaign do
  use Ash.Resource,
    otp_app: :five_apps,
    domain: FiveApps.Campaigns,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  postgres do
    table "campaigns"
    repo FiveApps.Repo

    references do
      reference :stash, on_delete: :delete
      reference :ship, on_delete: :delete
    end
  end

  json_api do
    type "campaign"
  end

  actions do
    defaults [:read]

    create :create do
      accept [:name, :description]
      argument :stash, :map, default: %{}
      argument :ship, :map, default: %{}

      change manage_relationship(:stash, type: :direct_control)
      change manage_relationship(:ship, type: :direct_control)
    end

    update :update do
      accept [
        :name,
        :description,
        :status,
        :story_points,
        :turn_number,
        :difficulty,
        :victory,
        :notes
      ]

      argument :stash, :map, default: %{}
      argument :ship, :map, default: %{}

      require_atomic? false

      change manage_relationship(:stash, type: :direct_control)
      change manage_relationship(:ship, type: :direct_control)
    end

    destroy :destroy do
      accept [:id, :name]

      change cascade_destroy(:stash, action: :destroy, after_action?: false)
      change cascade_destroy(:ship, action: :destroy, after_action?: false)
    end
  end

  changes do
    change relate_actor(:owner, allow_nil?: true), on: [:create]
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

    attribute :status, :atom do
      public? true
      default :creating
      constraints one_of: [:creating, :active, :abandoned]
    end

    attribute :story_points, :integer do
      public? true
      default 0
    end

    attribute :turn_number, :integer do
      public? true
      default 0
    end

    attribute :difficulty, :atom do
      public? true
      default :normal
      constraints one_of: [:easy, :normal, :challenging, :hardcore, :insanity]
    end

    attribute :victory, :string do
      public? true
      allow_nil? true
    end

    attribute :notes, :string do
      public? true
      allow_nil? true
    end

    # Owner attribute (references the user who created the campaign)
    attribute :owner_id, :uuid do
      public? true
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :owner, FiveApps.Accounts.User
    has_many :crew_members, FiveApps.Campaigns.CrewMember
    has_one :stash, FiveApps.Campaigns.Stash
    has_one :ship, FiveApps.Campaigns.Ship
  end
end
