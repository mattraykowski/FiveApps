defmodule FiveApps.CampaignsTest do
  use FiveApps.DataCase, async: true

  alias FiveApps.Campaigns
  alias FiveApps.Campaigns.Campaign

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
      assert Campaigns.get_campaign(campaign.id) == nil
    end
  end
end
