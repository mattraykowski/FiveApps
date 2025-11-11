# Quickstart Guide: Crew Member Leader Assignment

**Feature**: 001-as-a-player
**Branch**: `001-as-a-player`
**Date**: 2025-10-16

## Overview

This guide walks through implementing the crew member leader designation feature, following TDD principles and the Five Apps Constitution.

**Feature Summary**: Allow players to designate exactly one crew member per campaign as the leader, with a toggle control for easy switching and visual indicators to identify the current leader.

**Estimated Time**: 2-4 hours for P1 (core functionality), +1 hour for P2 (visual indicators), +30 min for P3 (remove leader)

## Prerequisites

- [ ] Branch `001-as-a-player` checked out
- [ ] All existing tests passing (`mix test`)
- [ ] Database migrated (`mix ash.migrate`)
- [ ] Dev server running (`mix phx.server`)

## Implementation Phases

### Phase 1: Resource Layer (TDD - Red Phase)

**Goal**: Add `is_leader` attribute to CrewMember with validation

#### Step 1.1: Write Failing Resource Tests

**File**: `test/five_apps/campaigns/crew_member_test.exs`

```elixir
defmodule FiveApps.Campaigns.CrewMemberTest do
  use FiveApps.DataCase, async: true

  alias FiveApps.Campaigns

  describe "is_leader attribute" do
    setup do
      user = create_user()
      {:ok, campaign} = Campaigns.create_campaign(%{name: "Test Campaign"}, actor: user)
      {:ok, crew_a} = Campaigns.create_crew_member(%{
        name: "Alice",
        species: "Human",
        campaign_id: campaign.id
      }, actor: user)
      {:ok, crew_b} = Campaigns.create_crew_member(%{
        name: "Bob",
        species: "Alien",
        campaign_id: campaign.id
      }, actor: user)

      %{user: user, campaign: campaign, crew_a: crew_a, crew_b: crew_b}
    end

    test "defaults to false", %{crew_a: crew} do
      assert crew.is_leader == false
    end

    test "can be set to true", %{user: user, crew_a: crew} do
      {:ok, updated} = Campaigns.update_crew_member(crew, %{is_leader: true}, actor: user)
      assert updated.is_leader == true
    end

    test "enforces one leader per campaign", %{user: user, crew_a: crew_a, crew_b: crew_b} do
      # Set crew_a as leader
      {:ok, _} = Campaigns.update_crew_member(crew_a, %{is_leader: true}, actor: user)

      # Set crew_b as leader
      {:ok, _} = Campaigns.update_crew_member(crew_b, %{is_leader: true}, actor: user)

      # Verify only crew_b is leader
      reloaded_a = Campaigns.get_crew_member!(crew_a.id)
      reloaded_b = Campaigns.get_crew_member!(crew_b.id)

      assert reloaded_a.is_leader == false
      assert reloaded_b.is_leader == true
    end

    test "allows removing leader", %{user: user, crew_a: crew} do
      {:ok, updated} = Campaigns.update_crew_member(crew, %{is_leader: true}, actor: user)
      assert updated.is_leader == true

      {:ok, updated} = Campaigns.update_crew_member(updated, %{is_leader: false}, actor: user)
      assert updated.is_leader == false
    end
  end

  # Helper function (add to test_helpers or inline)
  defp create_user do
    # Use your existing user fixture/factory
    # Example:
    {:ok, user} = FiveApps.Accounts.register_user(%{
      email: "test-#{System.unique_integer()}@example.com",
      password: "password123password123"
    })
    user
  end
end
```

**Run tests** (should FAIL):
```bash
mix test test/five_apps/campaigns/crew_member_test.exs
```

**Expected failures**: `is_leader` field doesn't exist

#### Step 1.2: Add Attribute to Resource (Green Phase)

**File**: `lib/five_apps/campaigns/crew_member.ex`

Add to attributes section:

```elixir
attributes do
  uuid_primary_key :id

  # ... existing attributes ...

  attribute :is_leader, :boolean do
    default false
    allow_nil? false
    public? true
  end

  timestamps()
end
```

Update the `:update` action to accept `:is_leader`:

```elixir
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
    :savvy,
    :luck,
    :experience,
    :is_leader  # ADD THIS
  ]

  # ... rest of action ...
end
```

#### Step 1.3: Generate and Run Dev Migration

```bash
mix ash.codegen --dev
```

**Verify** the migration adds the column, then run it:

```bash
mix ash.migrate
```

#### Step 1.4: Add Domain Code Interface

**File**: `lib/five_apps/campaigns.ex`

Add or ensure this function exists:

```elixir
resource FiveApps.Campaigns.CrewMember do
  define :create_crew_member, action: :create
  define :update_crew_member, action: :update
  define :delete_crew_member, action: :destroy
  define :get_crew_member, action: :read, get_by: [:id]  # ADD if missing
end
```

**Run tests** (should now PASS for basic attribute tests, FAIL for constraint test):
```bash
mix test test/five_apps/campaigns/crew_member_test.exs
```

#### Step 1.5: Implement EnsureSingleLeader Change (Green Phase)

**File**: `lib/five_apps/campaigns/changes/ensure_single_leader.ex` (NEW)

```elixir
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
    |> Ash.read!()
    |> Enum.each(fn crew_member ->
      crew_member
      |> Ash.Changeset.for_update(:update, %{is_leader: false})
      |> Ash.update!()
    end)
  end
end
```

**File**: `lib/five_apps/campaigns/crew_member.ex`

Add the change to the `:update` action:

```elixir
update :update do
  accept [
    # ... existing fields ...
    :is_leader
  ]

  argument :weapons, {:array, :map}, default: []

  require_atomic? false

  # ADD THIS LINE:
  change FiveApps.Campaigns.Changes.EnsureSingleLeader

  change manage_relationship(:weapons, type: :direct_control)
end
```

**Run tests** (should all PASS now):
```bash
mix test test/five_apps/campaigns/crew_member_test.exs
```

### Phase 2: LiveView Integration (TDD - Red Phase)

**Goal**: Add toggle control to UI with event handling

#### Step 2.1: Write Failing LiveView Tests

**File**: `test/five_apps_web/live/campaigns/show_test.exs`

Add to existing test file:

```elixir
describe "crew member leader toggle" do
  setup do
    user = register_and_log_in_user(%{conn: build_conn()})
    {:ok, campaign} = Campaigns.create_campaign(%{name: "Test"}, actor: user.user)
    {:ok, crew} = Campaigns.create_crew_member(%{
      name: "Test Crew",
      species: "Human",
      campaign_id: campaign.id
    }, actor: user.user)

    %{user: user, campaign: campaign, crew: crew}
  end

  test "toggle sets crew member as leader", %{conn: conn, campaign: campaign, crew: crew} do
    {:ok, view, _html} = live(conn, ~p"/campaigns/#{campaign.id}")

    # Click toggle (will need to implement phx-click handler)
    view
    |> element("[data-test-id='leader-toggle-#{crew.id}']")
    |> render_click()

    # Should see success message
    assert render(view) =~ "Leader updated"

    # Verify crew member is leader
    updated = Campaigns.get_crew_member!(crew.id)
    assert updated.is_leader == true
  end
end
```

**Run tests** (should FAIL):
```bash
mix test test/five_apps_web/live/campaigns/show_test.exs
```

#### Step 2.2: Add Toggle to Template (Green Phase)

**File**: `lib/five_apps_web/live/campaigns/show.html.heex`

Find the crew member card section (around line 167-190) and modify:

**BEFORE**:
```heex
<div class="flex justify-between items-start mb-2">
  <h3 class="text-lg font-bold"><%= crew_member.name %></h3>
  <div class="flex gap-2 items-center">
    <.badge color="primary"><%= crew_member.class || "No Class" %></.badge>
    <.button ... phx-click="open_edit_modal" ...>Edit</.button>
    <.button ... phx-click="open_delete_modal" ...>Delete</.button>
  </div>
</div>
```

**AFTER**:
```heex
<div class="flex justify-between items-start mb-2">
  <div class="flex gap-2 items-center">
    <h3 class="text-lg font-bold"><%= crew_member.name %></h3>
    <.badge color="primary"><%= crew_member.class || "No Class" %></.badge>
  </div>
  <div class="flex gap-2 items-center">
    <.toggle
      data-test-id={"leader-toggle-#{crew_member.id}"}
      checked={crew_member.is_leader}
      phx-click="toggle_leader"
      phx-value-crew_member_id={crew_member.id}
      phx-value-is_leader={!crew_member.is_leader}
      color="primary"
      aria-label="Set as crew leader"
    />
    <.button ... phx-click="open_edit_modal" ...>Edit</.button>
    <.button ... phx-click="open_delete_modal" ...>Delete</.button>
  </div>
</div>
```

#### Step 2.3: Add Event Handler (Green Phase)

**File**: `lib/five_apps_web/live/campaigns/show.ex`

Add handler function:

```elixir
def handle_event("toggle_leader", %{"crew_member_id" => id, "is_leader" => is_leader_str}, socket) do
  is_leader = is_leader_str == "true"
  crew_member = Enum.find(socket.assigns.campaign.crew_members, &(&1.id == id))

  case Campaigns.update_crew_member(
    crew_member,
    %{is_leader: is_leader},
    actor: socket.assigns.current_user
  ) do
    {:ok, _updated} ->
      # Reload campaign with updated crew
      campaign = Campaigns.get_campaign!(
        socket.assigns.campaign.id,
        load: [:ship, :stash, crew_members: [:weapons]]
      )

      {:noreply,
       socket
       |> assign(:campaign, campaign)
       |> put_flash(:info, "Leader updated")}

    {:error, _changeset} ->
      {:noreply, put_flash(socket, :error, "Failed to update leader")}
  end
end
```

**Run tests** (should PASS):
```bash
mix test test/five_apps_web/live/campaigns/show_test.exs
```

### Phase 3: Visual Indicator (P2 - Optional)

**Goal**: Add visual badge/icon to show leader status

**File**: `lib/five_apps_web/live/campaigns/show.html.heex`

Add leader indicator after name:

```heex
<div class="flex gap-2 items-center">
  <h3 class="text-lg font-bold">
    <%= crew_member.name %>
    <%= if crew_member.is_leader do %>
      <.icon name="hero-star-solid" class="w-5 h-5 text-warning inline ml-1" />
    <% end %>
  </h3>
  <.badge color="primary"><%= crew_member.class || "No Class" %></.badge>
</div>
```

**Manual testing**: Start dev server and verify icon appears next to leader name.

### Phase 4: Final Migration

**Goal**: Create production-ready migration

#### Step 4.1: Squash Dev Migrations

```bash
mix ash.codegen add_leader_to_crew_members
```

This will:
- Roll back dev migrations
- Create a named migration
- Squash all changes into one migration

#### Step 4.2: Verify Migration

Check the generated file in `priv/repo/migrations/`:

```elixir
defmodule FiveApps.Repo.Migrations.AddLeaderToCrewMembers do
  use Ecto.Migration

  def up do
    alter table(:crew_members) do
      add :is_leader, :boolean, default: false, null: false
    end
  end

  def down do
    alter table(:crew_members) do
      remove :is_leader
    end
  end
end
```

#### Step 4.3: Test Migration Reversibility

```bash
# Run migration
mix ecto.migrate

# Rollback
mix ecto.rollback

# Re-run
mix ecto.migrate
```

### Phase 5: Manual Testing Checklist

- [ ] Start dev server: `mix phx.server`
- [ ] Navigate to campaign with crew members: `http://localhost:4000/campaigns/<id>`
- [ ] Click "Crew Members" tab
- [ ] **Test P1 - Basic toggle**:
  - [ ] Click toggle on first crew member → toggle turns on, flash message appears
  - [ ] Click toggle on second crew member → toggle turns on, first toggle turns off
  - [ ] Click toggle on second crew member again → toggle turns off
- [ ] **Test P2 - Visual indicator**:
  - [ ] Set a crew member as leader
  - [ ] Verify star icon appears next to their name
  - [ ] Switch leader to different crew member
  - [ ] Verify star moves to new leader
- [ ] **Test P3 - Remove leader**:
  - [ ] Set a crew member as leader
  - [ ] Click toggle to turn off
  - [ ] Verify no crew member has leader indicator
- [ ] **Test Edge Cases**:
  - [ ] Delete current leader → no error, no leader remains
  - [ ] Rapid toggle clicks → last click wins, consistent state
- [ ] **Test Accessibility**:
  - [ ] Tab to toggle using keyboard
  - [ ] Press Space or Enter → toggle activates
  - [ ] Use screen reader → announces "Set as crew leader, checkbox"

## Common Issues & Troubleshooting

### Issue: "is_leader field not found"

**Cause**: Migration not run
**Fix**: `mix ash.migrate`

### Issue: "Multiple crew members are leaders"

**Cause**: `EnsureSingleLeader` change not applied
**Fix**: Verify change is added to `:update` action in `crew_member.ex`

### Issue: Toggle click doesn't work

**Cause**: Event handler not properly wired
**Fix**: Check `phx-click` attribute matches handler function name

### Issue: "Function Campaigns.update_crew_member/3 is undefined"

**Cause**: Domain code interface not defined
**Fix**: Add `define :update_crew_member, action: :update` to `campaigns.ex`

### Issue: Toggle shows wrong state after click

**Cause**: Campaign not reloaded after update
**Fix**: Ensure `Campaigns.get_campaign!` is called in success case with `load:` option

## Validation Steps

### Pre-Commit Checklist

- [ ] All tests pass: `mix test`
- [ ] Code formatted: `mix format`
- [ ] Credo clean: `mix credo --strict`
- [ ] Manual testing completed (above checklist)
- [ ] Migration tested (up and down)
- [ ] Browser console has no errors

### Pre-Merge Checklist

- [ ] All tests pass in CI
- [ ] Feature demonstrated to stakeholder
- [ ] Documentation updated (this guide + CLAUDE.md if needed)
- [ ] Code reviewed

## Next Steps

After completing this feature:

1. **Generate tasks**: Run `/speckit.tasks` to create detailed task breakdown
2. **Follow TDD**: Red → Green → Refactor for each task
3. **Commit frequently**: After each green phase
4. **Update docs**: Document any deviations or learnings

## Time Estimates

| Phase | Estimated Time | Notes |
|-------|----------------|-------|
| Phase 1: Resource Layer | 1-1.5 hours | Includes test writing + implementation |
| Phase 2: LiveView | 0.5-1 hour | Includes event handling + UI update |
| Phase 3: Visual Indicator | 0.5 hours | Simple UI enhancement |
| Phase 4: Final Migration | 0.25 hours | Squash and verify |
| Phase 5: Manual Testing | 0.5 hours | Comprehensive testing |
| **Total** | **2.75-3.75 hours** | P1 + P2 complete |

**MVP (P1 only)**: ~2 hours
**Full Feature (P1 + P2 + P3)**: ~3-4 hours

## Success Criteria

✅ Feature complete when:

- All ExUnit tests pass
- Toggle control works in browser
- One-leader-per-campaign enforced
- Visual indicator shows current leader
- Flash messages provide feedback
- Migration is reversible
- Code follows constitution principles (TDD, domain interfaces, accessibility)
