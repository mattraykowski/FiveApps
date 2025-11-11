# Research: Crew Member Leader Assignment

**Feature**: 001-as-a-player
**Date**: 2025-10-16
**Purpose**: Technical research for implementing leader designation on crew members

## Research Questions

### Q1: How to enforce one-leader-per-campaign constraint in Ash Framework?

**Decision**: Use custom Ash change with validation logic in the `update` action

**Rationale**:
- Ash Framework provides `change` modules for custom business logic during resource lifecycle
- A custom change can query sibling crew members in the same campaign and clear their leader flags
- This approach keeps business logic in the domain layer (not database triggers)
- Allows for better error messages and transaction control
- Follows Ash Framework best practices documented in official guides

**Implementation Approach**:
```elixir
# In lib/five_apps/campaigns/crew_member.ex
defmodule FiveApps.Campaigns.Changes.EnsureSingleLeader do
  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    # If is_leader being set to true, clear other leaders in campaign
    # If is_leader being set to false, no action needed
  end
end
```

**Alternatives Considered**:
1. **Database unique partial index** - Would work but requires dropping down to raw SQL, less portable
2. **Application-level validation only** - Race conditions possible with concurrent requests
3. **Campaign has_one :leader relationship** - More complex data model, harder to query all crew members

**Best Practice Source**: Ash Framework documentation on custom changes and validations

### Q2: How to implement optimistic UI updates for the toggle?

**Decision**: Use Phoenix LiveView's existing form handling with `phx-change` event

**Rationale**:
- LiveView already handles optimistic updates well with standard event handlers
- Toggle click triggers `phx-click` event that immediately updates assigns
- Flash message provides confirmation feedback
- If save fails, LiveView automatically reverts state and shows error
- No need for JavaScript or custom optimistic locking

**Implementation Approach**:
```elixir
# In show.ex
def handle_event("toggle_leader", %{"crew_member_id" => id, "is_leader" => is_leader_str}, socket) do
  is_leader = is_leader_str == "true"
  crew_member = find_crew_member(socket, id)

  case Campaigns.update_crew_member(crew_member, %{is_leader: is_leader}, actor: socket.assigns.current_user) do
    {:ok, _} ->
      campaign = reload_campaign_with_crew(socket)
      {:noreply, socket |> assign(:campaign, campaign) |> put_flash(:info, "Leader updated")}
    {:error, _} ->
      {:noreply, put_flash(socket, :error, "Failed to update leader")}
  end
end
```

**Alternatives Considered**:
1. **JavaScript with Alpine.js** - Adds complexity, not needed for simple toggle
2. **LiveView.JS commands for animations** - Could enhance but not required for MVP
3. **Debouncing toggle events** - Not needed, single click operation

**Best Practice Source**: Phoenix LiveView documentation on handling form events

### Q3: Where to place the toggle control in the crew member card UI?

**Decision**: Place toggle to the left of the edit button, move class badge next to name

**Rationale**:
- User explicitly requested this layout in planning input
- Keeps action buttons grouped together on the right side of card header
- Toggle is visually associated with the edit/delete actions
- Moving class badge next to name improves information hierarchy (identity info together)
- Maintains responsive layout on tablets (current flex layout already handles this)

**Current Layout** (line 168-190 in show.html.heex):
```html
<div class="flex justify-between items-start mb-2">
  <h3 class="text-lg font-bold"><%= crew_member.name %></h3>
  <div class="flex gap-2 items-center">
    <.badge color="primary"><%= crew_member.class || "No Class" %></.badge>
    <.button phx-click="open_edit_modal" ...>Edit</.button>
    <.button phx-click="open_delete_modal" ...>Delete</.button>
  </div>
</div>
```

**New Layout**:
```html
<div class="flex justify-between items-start mb-2">
  <div class="flex gap-2 items-center">
    <h3 class="text-lg font-bold"><%= crew_member.name %></h3>
    <.badge color="primary"><%= crew_member.class || "No Class" %></.badge>
  </div>
  <div class="flex gap-2 items-center">
    <.toggle
      checked={crew_member.is_leader}
      phx-click="toggle_leader"
      phx-value-crew_member_id={crew_member.id}
      aria-label="Set as crew leader"
    />
    <.button phx-click="open_edit_modal" ...>Edit</.button>
    <.button phx-click="open_delete_modal" ...>Delete</.button>
  </div>
</div>
```

**Accessibility Considerations**:
- Toggle has `aria-label` for screen readers
- Native checkbox semantics provide keyboard navigation
- Visual focus indicator provided by DaisyUI

**Alternatives Considered**:
1. **Toggle in a separate row** - Takes more vertical space, less efficient use of card
2. **Toggle as overlay on card** - Could be confusing, not standard pattern
3. **Dropdown menu for leader actions** - Over-engineered for simple boolean toggle

### Q4: How to handle leader deletion cascade?

**Decision**: Use Ash Framework's existing cascade deletion with the `update` action

**Rationale**:
- CrewMember already has `destroy` action with `cascade_destroy(:weapons, ...)` pattern
- When crew member is deleted, `is_leader` flag automatically removed (record deleted)
- No special handling needed - leader just becomes unset for campaign
- Follows existing pattern in codebase

**Implementation**:
```elixir
# No changes needed - existing destroy action handles this
destroy :destroy do
  accept [:id]
  change cascade_destroy(:weapons, action: :destroy, after_action?: false)
end
```

**Edge Case Handling**:
- Campaign can have zero leaders after deletion (valid state per spec)
- UI shows no leader indicator when no crew member has `is_leader: true`
- Player can designate new leader at any time

**Alternatives Considered**:
1. **Prevent deletion of leader** - Too restrictive, spec allows leader removal
2. **Auto-promote next crew member** - Not requested, adds complexity
3. **Soft delete with archive flag** - Out of scope for this feature

**Best Practice Source**: Existing CrewMember resource code pattern

## Technical Decisions Summary

| Decision | Approach | Rationale |
|----------|----------|-----------|
| **One-leader constraint** | Custom Ash change module | Domain logic stays in Ash layer, good error handling |
| **UI updates** | Standard LiveView event handling | Simple, reliable, follows Phoenix patterns |
| **UI layout** | Toggle left of edit button, badge by name | User requested, maintains visual hierarchy |
| **Leader deletion** | No special handling needed | Existing cascade works, simple state management |
| **Data model** | Boolean `is_leader` attribute | Simple, efficient, easy to query and update |

## Dependencies & Libraries

**Existing Dependencies** (no new additions needed):
- `ash ~> 3.0` - Resource framework
- `ash_postgres ~> 2.0` - Data layer
- `ash_phoenix ~> 2.0` - LiveView integration
- `phoenix_live_view ~> 1.0.9` - UI framework
- `tailwindcss` - Styling
- `daisyui` - UI components (Toggle already available)

**No new dependencies required** - all necessary tools already in project.

## Performance Considerations

**Database Impact**:
- New boolean column `is_leader` with default `false`
- No index needed initially (campaign has small number of crew members typically)
- If performance issues arise, can add partial index: `WHERE is_leader = true`

**Query Performance**:
- Existing query already loads all crew members: `load: [crew_members: [:weapons]]`
- No additional queries needed
- Toggle update is single UPDATE statement scoped to campaign

**UI Performance**:
- Toggle interaction is immediate (standard HTML checkbox)
- LiveView update cycle < 50ms for typical network latency
- Flash message appears instantly after server confirmation
- No JavaScript bundle increase (using existing components)

**Scalability**:
- Feature scoped to single campaign context (no cross-campaign queries)
- Crew members per campaign typically < 50 (game rules)
- UPDATE query uses primary key lookups (highly efficient)
- No N+1 query issues

## Security Considerations

**Authorization**:
- Existing Ash policies apply (user must own campaign)
- Actor context passed through domain interface
- No new attack surface introduced

**Data Integrity**:
- Custom change ensures one-leader-per-campaign atomically
- Database transaction handles concurrent updates
- Validation errors return helpful messages

**Input Validation**:
- Boolean type enforced by Ash attribute definition
- Campaign scoping prevents cross-campaign manipulation
- Existing CSRF protection applies (LiveView)

## Testing Strategy

**Test Pyramid**:
1. **Unit Tests** (Resource layer) - 70% coverage
   - Boolean attribute accepts true/false
   - Setting leader clears other leaders in campaign
   - Leader can be unset (set to false)
   - Leader deleted removes leader designation

2. **Integration Tests** (Domain layer) - 20% coverage
   - Multiple crew members, one leader enforced
   - Leader transition works correctly
   - Concurrent updates handled safely

3. **LiveView Tests** (UI layer) - 10% coverage
   - Toggle renders correctly
   - Toggle click updates crew member
   - Flash message appears
   - Visual indicator shows leader

**Test Frameworks**:
- ExUnit for all tests
- `Ash.Test` helpers for resource tests
- `Phoenix.LiveViewTest` for UI tests
- `Ecto.Adapters.SQL.Sandbox` for database isolation

## Migration Strategy

**Development Process**:
1. Run `mix ash.codegen --dev` after adding `:is_leader` attribute
2. Test with dev migration
3. Iterate on custom change logic
4. Run `mix ash.codegen add_leader_to_crew_members` for final migration

**Production Deployment**:
1. Migration adds column with default `false` (safe, no downtime)
2. Existing data unaffected (all crew members start as non-leaders)
3. No data backfill needed
4. Reversible via `down` function (drops column)

**Rollback Plan**:
- Run migration down: `mix ecto.rollback`
- Remove attribute from resource
- Remove custom change module
- Remove UI components

## Open Questions

✅ All questions resolved during research phase.

## References

- [Ash Framework Changes Documentation](https://hexdocs.pm/ash/changes.html)
- [Phoenix LiveView Form Events](https://hexdocs.pm/phoenix_live_view/form-bindings.html)
- [DaisyUI Toggle Component](https://daisyui.com/components/toggle/)
- [Ash Postgres Migrations](https://hexdocs.pm/ash_postgres/migrations.html)
- Existing project code in `lib/five_apps/campaigns/crew_member.ex`
- Existing project code in `lib/five_apps_web/live/campaigns/show.ex`