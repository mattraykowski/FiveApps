defmodule FiveApps.Campaigns.Changes.EnsureSingleLeader do
  @moduledoc """
  Ensures only one crew member can be leader per campaign.

  When a crew member's is_leader is set to true, all other crew members
  in the same campaign have their is_leader flag set to false.
  """

  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    case Ash.Changeset.get_attribute(changeset, :is_leader) do
      true ->
        # Get the campaign_id from the current record
        campaign_id =
          Ash.Changeset.get_attribute(changeset, :campaign_id) ||
            changeset.data.campaign_id

        if campaign_id do
          Ash.Changeset.after_action(changeset, fn _changeset, record ->
            clear_other_leaders(record, campaign_id)
            {:ok, record}
          end)
        else
          changeset
        end

      _other ->
        changeset
    end
  end

  defp clear_other_leaders(current_crew_member, campaign_id) do
    FiveApps.Campaigns.CrewMember
    |> Ash.Query.filter(
      campaign_id == ^campaign_id and
        id != ^current_crew_member.id and
        is_leader == true
    )
    |> Ash.bulk_update!(:update, %{is_leader: false}, strategy: :stream)
  end
end
