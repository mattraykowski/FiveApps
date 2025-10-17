defmodule FiveApps.CampaignsTest do
  use FiveApps.DataCase, async: true

  alias FiveApps.Campaigns

  describe "FiveApps.Campaigns.list_campaigns!" do
    test "when there are no campaigns, nothing is returned" do
      assert Campaigns.list_campaigns!() == []
    end
  end

  describe "FiveApps.Campaigns.create_campaign" do
    test "stores the actor that created the campaign" do
      actor = generate(user())

      {:ok, campaign} = Campaigns.create_campaign(%{name: "Test Campaign"}, actor: actor)

      assert campaign.owner_id == actor.id
    end

    test "creates an empty ship and stash" do
      actor = generate(user())

      {:ok, campaign} =
        Campaigns.create_campaign(%{name: "Test Campaign"}, actor: actor, load: [:stash, :ship])

      assert campaign.stash.id != nil
      assert campaign.ship.id != nil
      assert campaign.ship.name == nil
      assert campaign.stash.notes == nil
    end

    test "creates a campaign with a stash" do
      actor = generate(user())

      {:ok, campaign} =
        Campaigns.create_campaign(
          %{
            name: "Test Campaign",
            stash: %{notes: "test notes", credits: 1, patrons: 1, rivals: 1}
          },
          actor: actor,
          load: [:stash]
        )

      assert campaign.stash.id != nil
      assert campaign.stash.notes == "test notes"
      assert campaign.stash.credits == 1
      assert campaign.stash.patrons == 1
      assert campaign.stash.rivals == 1
    end

    test "creates a campaign with a ship" do
      actor = generate(user())

      {:ok, campaign} =
        Campaigns.create_campaign(
          %{
            name: "Test Campaign",
            ship: %{name: "test ship"}
          },
          actor: actor,
          load: [:ship]
        )

      assert campaign.ship.id != nil
      assert campaign.ship.name == "test ship"
    end
  end

  describe "FiveApps.Campaigns.delete_campaign" do
    test "deletes the campaign" do
      campaign = generate(campaign())

      assert :ok = Campaigns.delete_campaign(campaign.id)
      assert {:error, _} = Campaigns.get_campaign(campaign.id)
    end
  end

  describe "FiveApps.Campaigns.create_crew_member" do
    test "creates a crew member for a campaign" do
      campaign = generate(campaign())

      {:ok, crew_member} =
        Campaigns.create_crew_member(%{
          name: "Test Crew Member",
          species: "Human",
          campaign_id: campaign.id
        })

      assert crew_member.name == "Test Crew Member"
      assert crew_member.species == "Human"
      assert crew_member.campaign_id == campaign.id
      assert crew_member.luck == 0
      assert crew_member.experience == 0
    end

    test "creates a crew member with weapons" do
      campaign = generate(campaign())

      {:ok, crew_member} =
        Campaigns.create_crew_member(
          %{
            name: "Armed Crew Member",
            species: "Human",
            campaign_id: campaign.id,
            weapons: [
              %{name: "Pistol", range: "12\"", shot: 2, damage: 1},
              %{name: "Knife", range: "Melee", shot: 1, damage: 1, traits: "Melee"}
            ]
          },
          load: [:weapons]
        )

      assert crew_member.name == "Armed Crew Member"
      assert length(crew_member.weapons) == 2
      weapon_names = Enum.map(crew_member.weapons, & &1.name)
      assert "Pistol" in weapon_names
      assert "Knife" in weapon_names
    end
  end

  describe "FiveApps.Campaigns.update_crew_member" do
    test "updates crew member weapons" do
      campaign = generate(campaign())

      {:ok, crew_member} =
        Campaigns.create_crew_member(
          %{
            name: "Test Crew Member",
            species: "Human",
            campaign_id: campaign.id,
            weapons: [
              %{name: "Old Pistol", range: "10\"", shot: 1, damage: 1}
            ]
          },
          load: [:weapons]
        )

      assert length(crew_member.weapons) == 1

      {:ok, updated_crew_member} =
        Campaigns.update_crew_member(
          crew_member,
          %{
            weapons: [
              %{name: "Plasma Rifle", range: "24\"", shot: 3, damage: 2, traits: "Energy"}
            ]
          },
          load: [:weapons]
        )

      assert length(updated_crew_member.weapons) == 1
      assert hd(updated_crew_member.weapons).name == "Plasma Rifle"
    end

    test "updates crew member luck and experience" do
      campaign = generate(campaign())

      {:ok, crew_member} =
        Campaigns.create_crew_member(%{
          name: "Veteran Crew Member",
          species: "Human",
          campaign_id: campaign.id
        })

      assert crew_member.luck == 0
      assert crew_member.experience == 0

      {:ok, updated_crew_member} =
        Campaigns.update_crew_member(crew_member, %{
          luck: 3,
          experience: 15
        })

      assert updated_crew_member.luck == 3
      assert updated_crew_member.experience == 15
    end
  end

  describe "FiveApps.Campaigns.delete_crew_member" do
    test "deletes crew member and cascades to weapons" do
      campaign = generate(campaign())

      {:ok, crew_member} =
        Campaigns.create_crew_member(
          %{
            name: "Test Crew Member",
            species: "Human",
            campaign_id: campaign.id,
            weapons: [
              %{name: "Pistol", range: "12\"", shot: 2, damage: 1}
            ]
          },
          load: [:weapons]
        )

      weapon_id = hd(crew_member.weapons).id

      assert :ok = Campaigns.delete_crew_member(crew_member)

      # Verify the weapon was also deleted
      assert {:error, %Ash.Error.Invalid{}} = Ash.get(FiveApps.Campaigns.Weapon, weapon_id)
    end
  end

  describe "Weapon resource" do
    test "creates a weapon for a crew member" do
      campaign = generate(campaign())

      {:ok, crew_member} =
        Campaigns.create_crew_member(%{
          name: "Test Crew Member",
          species: "Human",
          campaign_id: campaign.id
        })

      weapon =
        FiveApps.Campaigns.Weapon
        |> Ash.Changeset.for_create(:create, %{
          name: "Plasma Rifle",
          range: "24\"",
          shot: 3,
          damage: 2,
          traits: "Energy, Precise",
          crew_member_id: crew_member.id
        })
        |> Ash.create!()

      assert weapon.name == "Plasma Rifle"
      assert weapon.range == "24\""
      assert weapon.shot == 3
      assert weapon.damage == 2
      assert weapon.traits == "Energy, Precise"
      assert weapon.crew_member_id == crew_member.id
    end

    test "crew member can have multiple weapons" do
      campaign = generate(campaign())

      {:ok, crew_member} =
        Campaigns.create_crew_member(%{
          name: "Test Crew Member",
          species: "Human",
          campaign_id: campaign.id
        })

      FiveApps.Campaigns.Weapon
      |> Ash.Changeset.for_create(:create, %{
        name: "Pistol",
        range: "12\"",
        shot: 2,
        damage: 1,
        crew_member_id: crew_member.id
      })
      |> Ash.create!()

      FiveApps.Campaigns.Weapon
      |> Ash.Changeset.for_create(:create, %{
        name: "Knife",
        range: "Melee",
        shot: 1,
        damage: 1,
        traits: "Melee",
        crew_member_id: crew_member.id
      })
      |> Ash.create!()

      crew_member_with_weapons =
        FiveApps.Campaigns.CrewMember
        |> Ash.get!(crew_member.id, load: [:weapons])

      assert length(crew_member_with_weapons.weapons) == 2
      weapon_names = Enum.map(crew_member_with_weapons.weapons, & &1.name)
      assert "Pistol" in weapon_names
      assert "Knife" in weapon_names
    end
  end
end
