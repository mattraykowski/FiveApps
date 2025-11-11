# Implementation Plan: Crew Member Leader Assignment

**Branch**: `001-as-a-player` | **Date**: 2025-10-16 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-as-a-player/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Add the ability to designate exactly one crew member per campaign as the leader. Players will use a toggle control to set/unset the leader designation, with immediate save and visual feedback. The system enforces one-leader-per-campaign constraint at the data layer and automatically handles leader transitions when a new leader is designated or when the current leader is deleted.

**UI Placement**: Toggle control positioned to the left of the edit button on each crew member card. Class badge moved to the right of the crew member name for better visual hierarchy.

## Technical Context

**Language/Version**: Elixir 1.18
**Primary Dependencies**: Phoenix 1.8, LiveView 1.0.9, Ash Framework, AshPostgres, Tailwind CSS, DaisyUI
**Storage**: PostgreSQL with AshPostgres data layer
**Testing**: ExUnit with Ash.Test helpers, Phoenix.LiveViewTest for UI testing
**Target Platform**: Web browser (responsive design optimized for tablets 768px+)
**Project Type**: Phoenix LiveView web application with Ash Framework domain layer
**Performance Goals**: <200ms response time for leader toggle, instant visual feedback via optimistic updates
**Constraints**: Must maintain data integrity (one leader per campaign), must work on tablet form factors, must meet WCAG AA accessibility standards
**Scale/Scope**: Campaign-scoped feature affecting individual crew member resources within the FiveApps.Campaigns domain

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Ash Framework Domain-Driven Design ✅

- ✅ Feature adds boolean attribute to existing `CrewMember` resource in `FiveApps.Campaigns` domain
- ✅ Leader designation managed through Ash actions (update action on CrewMember)
- ✅ Constraint enforcement will use Ash validations and custom changes
- ✅ Uses existing `belongs_to :campaign` relationship for scoping
- ✅ Database schema changes managed through `mix ash.codegen` workflow

### II. Test-Driven Development (TDD) ✅

- ✅ Tests will be written first for each user story (P1, P2, P3)
- ✅ Red-Green-Refactor cycle will be followed
- ✅ ExUnit tests for resource actions and validations
- ✅ LiveView tests for UI interactions (toggle, visual indicators)
- ✅ Integration tests for leader transition scenarios

### III. Domain Code Interface Pattern ✅

- ✅ LiveView will call `Campaigns.update_crew_member/2` domain function
- ✅ No direct `Ash.update!` calls in web layer
- ✅ Actor context passed through domain functions
- ✅ Authorization handled by existing Ash policies

### IV. Responsive & Accessible UI ✅

- ✅ Toggle component already uses semantic HTML (checkbox input)
- ✅ Tailwind CSS used for layout
- ✅ DaisyUI Toggle component provides consistent UI
- ✅ Responsive grid layout works on tablets (current cards use `grid-cols-1 md:grid-cols-2`)
- ✅ ARIA labels will be added to toggle for accessibility
- ✅ Keyboard navigation supported by native checkbox element
- ✅ Flash messages provide feedback

### V. Iterative Migration Workflow ✅

- ✅ Will use `mix ash.codegen --dev` for iterative development
- ✅ Final migration named `add_leader_to_crew_members` when complete
- ✅ Migration will be reversible (drop column in `down`)

**Constitution Compliance**: ✅ PASS - All principles satisfied with existing patterns

## Project Structure

### Documentation (this feature)

```
specs/001-as-a-player/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
lib/
├── five_apps/
│   ├── campaigns/
│   │   ├── campaign.ex                      # Domain resource (no changes needed)
│   │   └── crew_member.ex                   # Add :is_leader attribute, validation, change
│   └── campaigns.ex                         # Domain module (add/update code interfaces)
│
├── five_apps_web/
│   ├── live/
│   │   └── campaigns/
│   │       ├── show.ex                      # Add handle_event for toggle_leader
│   │       └── show.html.heex               # Add toggle to crew member card, move badge
│   └── components/
│       └── daisy_ui_components/
│           └── toggle.ex                    # Existing component (no changes)

test/
├── five_apps/
│   └── campaigns/
│       └── crew_member_test.exs             # Resource tests for leader logic
└── five_apps_web/
    └── live/
        └── campaigns/
            └── show_test.exs                # LiveView tests for toggle interaction
```

**Structure Decision**: Phoenix LiveView web application with Ash Framework domain layer. The existing structure follows the Elixir/Phoenix convention with domain resources in `lib/five_apps/` and web layer in `lib/five_apps_web/`. Tests mirror the source structure in `test/`. This feature adds attributes and actions to existing resources without introducing new files except for enhanced tests.

## Complexity Tracking

*No constitution violations - this section is empty.*