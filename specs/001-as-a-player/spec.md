# Feature Specification: Crew Member Leader Assignment

**Feature Branch**: `001-as-a-player`
**Created**: 2025-10-16
**Status**: Draft
**Input**: User description: "As a player I want to be able to set a specific Crew Member as a leader but only one Crew Member at a time can be a leader so that I know which Crew Member is the leader when playing a game turn."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Designate Crew Member as Leader (Priority: P1)

As a player managing my campaign, I need to designate one crew member as the leader of my crew. This leader represents the character who makes key decisions and may have special abilities or responsibilities during game turns.

**Why this priority**: This is the core functionality requested - the ability to mark a crew member as leader. Without this, the feature has no value. This is the minimum viable feature.

**Independent Test**: Can be fully tested by creating a campaign with crew members, selecting one as leader, and verifying the leader flag is set while all others remain non-leaders. Delivers immediate value by allowing players to track their leader.

**Acceptance Scenarios**:

1. **Given** I have a campaign with multiple crew members and no leader assigned, **When** I designate crew member "Sarah Chen" as the leader, **Then** Sarah Chen is marked as the leader and all other crew members remain non-leaders
2. **Given** I have a campaign with crew member "John Smith" as the current leader, **When** I designate crew member "Maria Garcia" as the new leader, **Then** Maria Garcia becomes the leader and John Smith is automatically unmarked as leader
3. **Given** I have a campaign with multiple crew members, **When** I view the crew roster, **Then** I can clearly identify which crew member is the leader

---

### User Story 2 - Visual Leader Indicator (Priority: P2)

As a player viewing my crew roster, I want to see a clear visual indicator showing which crew member is the leader so I can quickly identify them without having to check each crew member's details.

**Why this priority**: While the underlying leader data (P1) is essential, the visual presentation enhances usability and makes the feature practical for gameplay. This is a natural extension of P1.

**Independent Test**: Can be tested by setting a leader (using P1 functionality) and verifying the leader has a distinct visual indicator (badge, icon, or styling) in the crew list that non-leaders don't have.

**Acceptance Scenarios**:

1. **Given** I have designated a crew member as leader, **When** I view the crew roster page, **Then** the leader has a visible badge or icon distinguishing them from other crew members
2. **Given** I am viewing crew member details, **When** the crew member is the leader, **Then** their detail page shows a clear leader indicator
3. **Given** I have not yet designated any crew member as leader, **When** I view the crew roster, **Then** no crew member shows a leader indicator

---

### User Story 3 - Remove Leader Designation (Priority: P3)

As a player, I want to remove the leader designation from my current leader without immediately assigning a new leader, so that I have flexibility in managing my crew during campaign transitions or special game scenarios.

**Why this priority**: This is a convenience feature for edge cases where a player wants no leader temporarily (e.g., leader character dies, campaign between scenarios). Nice to have but not essential for basic functionality.

**Independent Test**: Can be tested by setting a crew member as leader, then explicitly removing the leader designation, and verifying no crew member is marked as leader afterward.

**Acceptance Scenarios**:

1. **Given** I have a crew member designated as leader, **When** I remove their leader designation, **Then** no crew member in the campaign is marked as leader
2. **Given** I have removed the leader designation, **When** I later designate a new leader, **Then** the system allows me to set any crew member as the new leader

---

### Edge Cases

- What happens when the leader crew member is deleted from the campaign? (System should automatically unset the leader, leaving no leader assigned)
- What happens when a player tries to set a crew member from a different campaign as leader? (System must prevent this - crew members can only be leaders of their own campaign)
- What happens when a campaign has no crew members and a player tries to designate a leader? (System should prevent this or handle gracefully)
- What happens when a player tries to designate the same crew member as leader when they're already the leader? (System should handle this gracefully as a no-op)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow players to designate exactly one crew member per campaign as the leader
- **FR-002**: System MUST automatically remove leader designation from the previous leader when a new leader is designated
- **FR-003**: System MUST allow players to view which crew member is currently designated as the leader
- **FR-004**: System MUST allow players to remove leader designation without immediately assigning a new leader
- **FR-005**: System MUST prevent designating a crew member from a different campaign as leader
- **FR-006**: System MUST automatically remove leader designation when the leader crew member is deleted
- **FR-007**: System MUST persist the leader designation across sessions
- **FR-008**: System MUST display a visual indicator distinguishing the leader from other crew members in the crew roster
- **FR-009**: System MUST enforce the one-leader-per-campaign constraint at the data layer

### Key Entities

- **CrewMember**: Represents an individual crew member in a campaign. Currently has attributes for name, species, stats (reactions, speed, combat, toughness, savvy, luck, experience), and relationships to campaign and weapons. Will gain a new indicator showing whether this crew member is the current leader of their campaign.
- **Campaign**: Represents a game campaign that has multiple crew members. Will maintain the constraint that only one crew member can be leader at a time.

### Assumptions

- Players access this functionality through the existing campaign and crew member management interface
- The leader designation is a boolean flag rather than a separate leadership role system
- Visual indicators will follow existing UI patterns using DaisyUI components
- Leader designation is a simple flag without additional leader-specific attributes or permissions
- The feature uses existing authentication and authorization - players can only manage leaders in campaigns they own

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Players can designate a crew member as leader in under 10 seconds from the crew roster view
- **SC-002**: The leader indicator is visible and recognizable to players without requiring tooltips or help text
- **SC-003**: The system enforces the one-leader-per-campaign rule 100% of the time, with zero data integrity violations
- **SC-004**: Players can identify the current leader within 2 seconds of viewing the crew roster
- **SC-005**: 95% of players successfully designate a leader on their first attempt without errors or confusion