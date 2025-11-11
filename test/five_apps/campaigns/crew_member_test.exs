defmodule FiveApps.Campaigns.CrewMemberTest do
  use FiveApps.DataCase, async: true

  alias FiveApps.Campaigns

  describe "is_leader attribute" do
    setup do
      # Create a user using the generator
      user = generate(user())

      # Create a campaign
      {:ok, campaign} =
        Campaigns.create_campaign(%{name: "Test Campaign"}, actor: user)

      # Create crew members
      {:ok, crew_a} =
        Campaigns.create_crew_member(
          %{
            name: "Alice",
            species: "Human",
            campaign_id: campaign.id
          },
          actor: user
        )

      {:ok, crew_b} =
        Campaigns.create_crew_member(
          %{
            name: "Bob",
            species: "Alien",
            campaign_id: campaign.id
          },
          actor: user
        )

      %{user: user, campaign: campaign, crew_a: crew_a, crew_b: crew_b}
    end

    # T006: Test is_leader defaults to false
    test "defaults to false", %{crew_a: crew} do
      assert crew.is_leader == false
    end

    # T007: Test is_leader can be set to true
    test "can be set to true", %{user: user, crew_a: crew} do
      {:ok, updated} =
        Campaigns.set_crew_member_leader(crew, %{is_leader: true}, actor: user)

      assert updated.is_leader == true
    end

    # T008: Test one-leader-per-campaign constraint
    test "enforces one leader per campaign", %{
      user: user,
      crew_a: crew_a,
      crew_b: crew_b
    } do
      # Set crew_a as leader
      {:ok, _} =
        Campaigns.set_crew_member_leader(crew_a, %{is_leader: true}, actor: user)

      # Set crew_b as leader
      {:ok, _} =
        Campaigns.set_crew_member_leader(crew_b, %{is_leader: true}, actor: user)

      # Verify only crew_b is leader
      reloaded_a = Campaigns.get_crew_member!(crew_a.id)
      reloaded_b = Campaigns.get_crew_member!(crew_b.id)

      assert reloaded_a.is_leader == false
      assert reloaded_b.is_leader == true
    end

    # T009: Test removing leader designation
    test "allows removing leader", %{user: user, crew_a: crew} do
      {:ok, updated} =
        Campaigns.set_crew_member_leader(crew, %{is_leader: true}, actor: user)

      assert updated.is_leader == true

      {:ok, updated} =
        Campaigns.set_crew_member_leader(updated, %{is_leader: false}, actor: user)

      assert updated.is_leader == false
    end
  end
end
