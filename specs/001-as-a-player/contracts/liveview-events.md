# LiveView Event Contracts: Crew Member Leader Assignment

**Feature**: 001-as-a-player
**Date**: 2025-10-16
**Purpose**: Define LiveView event handling contracts for leader toggle interaction

## Event Contracts

### Event: `toggle_leader`

**Trigger**: User clicks the toggle control on a crew member card

**Direction**: Client → Server (LiveView)

**Payload**:

```elixir
%{
  "crew_member_id" => String.t(),  # UUID of the crew member
  "is_leader" => String.t()         # "true" or "false" (HTML checkbox value)
}
```

**Example**:

```elixir
%{
  "crew_member_id" => "550e8400-e29b-41d4-a716-446655440000",
  "is_leader" => "true"
}
```

**Handler**: `FiveAppsWeb.Campaigns.Show.handle_event/3`

**Processing**:

1. Parse `is_leader` string to boolean
2. Find crew member by ID in loaded campaign data
3. Call domain function `Campaigns.update_crew_member/3` with new `is_leader` value
4. If success: reload campaign, update socket assigns, show success flash
5. If error: keep current state, show error flash

**Response Behaviors**:

| Outcome | Socket Updates | Flash Message | HTTP Status |
|---------|----------------|---------------|-------------|
| Success | `assign(:campaign, updated_campaign)` | "Leader updated" (info) | 200 (implicit) |
| Error | No changes | "Failed to update leader" (error) | 200 (implicit) |
| Auth failure | No changes | "Unauthorized" (error) | 200 (implicit) |

**Implementation**:

```elixir
def handle_event("toggle_leader", %{"crew_member_id" => id, "is_leader" => is_leader_str}, socket) do
  is_leader = is_leader_str == "true"
  crew_member = Enum.find(socket.assigns.campaign.crew_members, &(&1.id == id))

  case Campaigns.update_crew_member(
    crew_member,
    %{is_leader: is_leader},
    actor: socket.assigns.current_user
  ) do
    {:ok, _updated_crew_member} ->
      # Reload campaign with all associations
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

**Edge Cases**:

| Scenario | Handling | Result |
|----------|----------|--------|
| Crew member not found | Return error flash | "Failed to update leader" |
| User not campaign owner | Ash authorization fails | "Unauthorized" or error flash |
| Concurrent toggle clicks | Last update wins | One leader remains |
| Toggle same state | No-op update | Success (idempotent) |
| Campaign has no crew | Toggle disabled in UI | N/A (prevented) |

## UI State Contracts

### Component: Leader Toggle

**Location**: `show.html.heex` line ~170-180 (in crew member card)

**Props**:

```elixir
<.toggle
  checked={crew_member.is_leader}              # boolean - current leader state
  phx-click="toggle_leader"                    # event name
  phx-value-crew_member_id={crew_member.id}   # UUID - identifies which crew member
  phx-value-is_leader={!crew_member.is_leader} # boolean - new state to set
  color="primary"                              # DaisyUI color variant
  aria-label="Set as crew leader"              # Accessibility label
/>
```

**Visual States**:

| State | `checked` Value | Visual Appearance | Interaction |
|-------|----------------|-------------------|-------------|
| Not leader | `false` | Toggle off (gray/neutral) | Click to enable |
| Is leader | `true` | Toggle on (primary color) | Click to disable |
| Saving | N/A (no special state) | Normal (LiveView handles) | Click blocked during save |
| Error | Same as before save | Normal + error flash | Click re-enabled |

**Accessibility**:

- **ARIA Label**: "Set as crew leader" - describes action
- **Role**: `checkbox` (implicit from input type)
- **Keyboard**: Space or Enter toggles (native HTML checkbox)
- **Focus**: Visible focus ring (DaisyUI default)
- **Screen Reader**: Announces "Set as crew leader, checkbox, checked/unchecked"

### Component: Leader Visual Indicator

**Location**: Various (crew member card, future detail view)

**Implementation Options**:

Option 1: Badge next to name (P2 user story):
```html
<div class="flex gap-2 items-center">
  <h3 class="text-lg font-bold"><%= crew_member.name %></h3>
  <%= if crew_member.is_leader do %>
    <.badge color="success">Leader</.badge>
  <% end %>
  <.badge color="primary"><%= crew_member.class || "No Class" %></.badge>
</div>
```

Option 2: Icon indicator:
```html
<h3 class="text-lg font-bold">
  <%= crew_member.name %>
  <%= if crew_member.is_leader do %>
    <.icon name="hero-star-solid" class="w-5 h-5 text-warning inline" />
  <% end %>
</h3>
```

**Decision**: Implement both - badge for explicit identification, icon for visual hierarchy.

## Domain Interface Contract

### Function: `update_crew_member/3`

**Location**: `lib/five_apps/campaigns.ex` (domain module)

**Signature**:

```elixir
@spec update_crew_member(CrewMember.t(), map(), keyword()) ::
  {:ok, CrewMember.t()} | {:error, Ash.Changeset.t()}

def update_crew_member(crew_member, params, opts \\ [])
```

**Parameters**:

- `crew_member` - The CrewMember struct to update
- `params` - Map of attributes to update (e.g., `%{is_leader: true}`)
- `opts` - Keyword list with `:actor` for authorization

**Returns**:

- `{:ok, updated_crew_member}` - Success, includes updated `is_leader` value
- `{:error, changeset}` - Validation or authorization failed

**Side Effects**:

When `is_leader: true` is set:
1. Target crew member has `is_leader` set to `true`
2. All other crew members in same campaign have `is_leader` set to `false` (via `EnsureSingleLeader` change)
3. Database transaction commits atomically
4. No side effects if `is_leader: false` is set

**Authorization**:

- Requires `actor` in opts
- Ash policy checks actor owns the campaign (via CrewMember → Campaign → User relationship)
- Returns `{:error, %{authorization: ...}}` if unauthorized

**Example Usage**:

```elixir
# In LiveView
crew_member = Enum.find(campaign.crew_members, &(&1.id == "some-uuid"))

case Campaigns.update_crew_member(
  crew_member,
  %{is_leader: true},
  actor: socket.assigns.current_user
) do
  {:ok, updated} -> # Success
  {:error, changeset} -> # Handle error
end
```

## Data Flow Diagram

```
┌─────────────┐
│   User      │
│  (Browser)  │
└──────┬──────┘
       │ 1. Click toggle
       │    phx-click="toggle_leader"
       │    data: {crew_member_id, is_leader}
       ▼
┌─────────────────────┐
│   LiveView          │
│   handle_event/3    │
└──────┬──────────────┘
       │ 2. Call domain function
       │    Campaigns.update_crew_member(...)
       ▼
┌─────────────────────┐
│   Domain Layer      │
│   FiveApps.Campaigns│
└──────┬──────────────┘
       │ 3. Create changeset
       │    via :update action
       ▼
┌─────────────────────┐
│   Resource Layer    │
│   CrewMember        │
│   + EnsureSingle... │
└──────┬──────────────┘
       │ 4a. Validate & save
       │ 4b. Clear other leaders
       │     (if is_leader=true)
       ▼
┌─────────────────────┐
│   Database          │
│   (PostgreSQL)      │
└──────┬──────────────┘
       │ 5. Return result
       ▼
┌─────────────────────┐
│   LiveView          │
│   {:noreply, socket}│
└──────┬──────────────┘
       │ 6. Reload campaign
       │    Update assigns
       │    Show flash
       ▼
┌─────────────┐
│   User      │
│  (Browser)  │
│  sees update│
└─────────────┘
```

**Latency Expectations**:

- Step 1-2: < 10ms (client → server)
- Step 2-5: < 50ms (domain logic + DB)
- Step 5-6: < 50ms (LiveView update)
- Step 6: < 20ms (render + push to client)
- **Total**: < 130ms typical, < 200ms p95

## Error Scenarios

### Scenario 1: Concurrent Leader Updates

**Setup**: Two users toggle different crew members as leader simultaneously

**Flow**:
1. User A toggles Crew Member 1 → leader
2. User B toggles Crew Member 2 → leader (within same transaction window)
3. Both requests hit database

**Outcome**:
- Transaction isolation ensures one completes first
- First update sets Crew Member 1 as leader
- Second update sets Crew Member 2 as leader, clears Crew Member 1
- Final state: Crew Member 2 is leader (last write wins)

**User Experience**:
- Both users see success flash
- Both users see Crew Member 2 as leader after page updates
- Consistent final state maintained

### Scenario 2: Authorization Failure

**Setup**: User tries to toggle leader on campaign they don't own

**Flow**:
1. User clicks toggle (somehow accessed other user's campaign)
2. `update_crew_member` called with their actor context
3. Ash authorization check fails
4. Returns `{:error, changeset}` with authorization error

**Outcome**:
- Error flash: "Failed to update leader" or "Unauthorized"
- Toggle returns to previous state
- No database changes

**Prevention**: Existing Ash policies prevent unauthorized access at domain layer.

### Scenario 3: Network Interruption

**Setup**: User toggles leader, network drops during save

**Flow**:
1. User clicks toggle
2. Request sent to server
3. Network interruption before response received

**Outcome**:
- LiveView connection management handles reconnection
- On reconnect, LiveView re-renders with current server state
- If save succeeded: User sees leader updated
- If save failed: User sees previous state, can retry

**User Experience**: Brief loading state, then correct state restored.

## Testing Contracts

### Unit Tests (Resource Layer)

```elixir
# test/five_apps/campaigns/crew_member_test.exs

describe "is_leader attribute" do
  test "defaults to false"
  test "can be set to true"
  test "can be set to false"
  test "enforces one leader per campaign" do
    # Create campaign with 2 crew members
    # Set first as leader
    # Set second as leader
    # Assert first is no longer leader
  end
end
```

### Integration Tests (Domain Layer)

```elixir
# test/five_apps/campaigns_test.exs

describe "update_crew_member/3 with leader flag" do
  test "sets crew member as leader"
  test "clears previous leader when new leader set"
  test "allows removing leader designation"
  test "handles concurrent updates safely"
end
```

### LiveView Tests (UI Layer)

```elixir
# test/five_apps_web/live/campaigns/show_test.exs

describe "leader toggle" do
  test "toggle click updates leader", %{conn: conn} do
    # Create campaign with crew members
    # Render page
    # Click toggle on crew member
    # Assert flash message
    # Assert crew member is leader
  end

  test "toggle shows visual indicator"
  test "toggle has accessibility label"
end
```

## Summary

| Contract Type | Location | Purpose |
|---------------|----------|---------|
| **Event** | `toggle_leader` | Handle user click on toggle |
| **Domain** | `update_crew_member/3` | Update leader designation with authorization |
| **Resource** | `CrewMember.is_leader` | Store and validate leader flag |
| **Change** | `EnsureSingleLeader` | Enforce one-leader constraint |
| **UI** | Toggle component | Provide accessible toggle control |
| **UI** | Visual indicator | Show leader status in crew list |

**Key Principles**:
- ✅ Atomic updates (transaction-safe)
- ✅ Authorization enforced at domain layer
- ✅ Accessible UI with ARIA labels
- ✅ Clear error handling with user feedback
- ✅ Idempotent operations (safe to retry)
