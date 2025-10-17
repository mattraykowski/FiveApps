<!--
Sync Impact Report:
Version: 0.0.0 → 1.0.0
Rationale: Initial constitution creation for Five Apps project

Principles Created:
- I. Ash Framework Domain-Driven Design
- II. Test-Driven Development (TDD)
- III. Domain Code Interface Pattern
- IV. Responsive & Accessible UI
- V. Iterative Migration Workflow

Sections Added:
- Core Principles
- Development Standards
- Quality Gates
- Governance

Templates Status:
- ✅ spec-template.md - Reviewed, aligns with TDD and user story focus
- ✅ plan-template.md - Reviewed, aligns with constitution checks and technical context
- ✅ tasks-template.md - Reviewed, aligns with test-first approach and phased delivery
- ✅ CLAUDE.md - Reviewed, existing guidance aligns with constitution principles

Follow-up TODOs: None - all placeholders filled
-->

# Five Apps Constitution

## Core Principles

### I. Ash Framework Domain-Driven Design

The application MUST organize business logic into Ash domains and resources following domain-driven design principles. All data operations MUST be defined using Ash actions (create, read, update, destroy, and custom actions).

**Non-negotiable rules:**
- Resources MUST be organized into cohesive Ash domains (e.g., `FiveApps.Accounts`, `FiveApps.Campaigns`)
- All business logic MUST be implemented using Ash actions, changes, validations, and calculations
- Resource relationships MUST use Ash relationship DSL (belongs_to, has_many, has_one)
- Authentication and authorization MUST leverage AshAuthentication and Ash policies
- Database schema changes MUST be managed through `mix ash.codegen` workflow

**Rationale:** Ash Framework provides declarative resource definitions, automatic API generation, built-in authorization, and consistent data layer abstractions. This reduces boilerplate, ensures consistency, and makes business logic auditable and testable.

### II. Test-Driven Development (TDD)

All feature development MUST follow test-driven development methodology using ExUnit. Tests MUST be written before implementation, MUST fail initially, and MUST pass after implementation.

**Non-negotiable rules:**
- Write tests FIRST for every feature or bug fix
- Verify tests FAIL before writing implementation code (Red phase)
- Implement minimum code to make tests pass (Green phase)
- Refactor while keeping tests passing (Refactor phase)
- All tests MUST use ExUnit framework
- Integration tests MUST use `Ash.Test.setup/1` helpers and database sandboxing
- LiveView tests MUST use `Phoenix.LiveViewTest` helpers
- Tests MUST NOT use `authorize?: false` except for administrative setup operations

**Rationale:** TDD ensures requirements are clear before coding begins, provides regression protection, serves as living documentation, and produces more testable, modular code. ExUnit provides excellent test isolation and async test execution for fast feedback cycles.

### III. Domain Code Interface Pattern

Web layer and external interfaces MUST interact with Ash resources exclusively through domain code interfaces, never directly through Ash module functions.

**Non-negotiable rules:**
- Define code interfaces in domain modules (e.g., `FiveApps.Campaigns` module)
- Web controllers and LiveViews MUST call domain functions, not `Ash.get!`, `Ash.create!`, etc.
- Domain functions MUST specify actor context and handle authorization
- Use `relate_actor(:owner)` changes to establish resource ownership on creation
- Load associations explicitly through domain functions using `:load` option

**Examples:**
```elixir
# GOOD - Domain code interface
FiveApps.Campaigns.get_campaign!(id, actor: current_user, load: [:ship, :stash, :crew_members])
FiveApps.Campaigns.create_campaign(attrs, actor: current_user)

# BAD - Direct Ash calls
Ash.get!(Campaign, id) |> Ash.load!([:ship, :stash])
Ash.create!(Campaign, attrs)
```

**Rationale:** Domain code interfaces provide a stable API boundary, centralize authorization logic, make testing easier, and allow flexibility to change underlying Ash implementation details without breaking consumers.

### IV. Responsive & Accessible UI

All user interfaces MUST be responsive, mobile-friendly, and accessible following WCAG 2.1 Level AA guidelines where feasible.

**Non-negotiable rules:**
- All LiveView templates MUST use semantic HTML5 elements
- Tailwind CSS utility classes MUST be used for styling
- DaisyUI components MUST be used for consistent UI patterns
- Layouts MUST be responsive and optimized for tablet form factors (768px and above)
- Interactive elements MUST have appropriate ARIA labels and keyboard navigation
- Forms MUST have proper labels, error messages, and validation feedback
- Color contrast MUST meet WCAG AA standards (4.5:1 for normal text)
- Focus indicators MUST be visible for keyboard navigation

**Rationale:** The application serves tabletop game players who may use tablets during gameplay. Responsive design ensures usability across device sizes. Accessibility ensures the application is usable by players with disabilities and improves overall usability for all users.

### V. Iterative Migration Workflow

Database schema changes MUST follow Ash's iterative development workflow for rapid iteration during development and atomic migrations for production.

**Non-negotiable rules:**
- Use `mix ash.codegen --dev` for iterative development and testing resource changes
- Continue iterating with `mix ash.codegen --dev` until feature is complete
- Generate final named migration with `mix ash.codegen [feature_name]` when ready
- Dev migrations will be automatically rolled back and squashed into final migration
- Avoid manual migration file editing unless absolutely necessary
- Test migrations in development environment before committing
- All migrations MUST be reversible (implement `down` functions)

**Rationale:** The iterative workflow allows rapid experimentation with resource definitions while keeping migration history clean. Squashing dev migrations into a final named migration prevents migration clutter and makes production deployments cleaner.

## Development Standards

### File Organization

**LiveView Structure:**
- Render logic MUST be in `.html.heex` template files (NOT inline in `.ex` files)
- LiveView components MUST be self-contained in `.ex` files
- LiveView modules MUST use appropriate `on_mount` hooks for authentication:
  - `on_mount {FiveAppsWeb.LiveUserAuth, :live_user_required}` for authenticated routes
  - `on_mount {FiveAppsWeb.LiveUserAuth, :live_user_optional}` for optional auth
  - `on_mount {FiveAppsWeb.LiveUserAuth, :live_no_user}` for public-only routes

**Component Organization:**
- DaisyUI components MUST be defined in `FiveAppsWeb.Components.DaisyUiComponents`
- Core Phoenix components MUST be defined in `FiveAppsWeb.Components.CoreComponents`
- Layout components MUST be defined in `FiveAppsWeb.Components.Layouts`
- Component modules MUST use Phoenix.Component DSL

**Helper Modules:**
- Utility functions MUST be organized by domain in `lib/five_apps/helpers/`
- Name generators MUST extend `FiveApps.Helpers.NameGenerator` base module
- Pure functions preferred for testability

### Code Quality

**Elixir Standards:**
- Code MUST pass `mix format` formatter
- Code SHOULD pass `mix credo` static analysis with minimal warnings
- Functions SHOULD have `@doc` and `@spec` annotations for public APIs
- Module documentation MUST include usage examples where appropriate

**Naming Conventions:**
- Modules: PascalCase (e.g., `FiveApps.Campaigns.Campaign`)
- Functions: snake_case (e.g., `get_campaign!`)
- Variables: snake_case (e.g., `crew_member`)
- Atoms: snake_case (e.g., `:crew_name`)
- Resources: singular nouns (e.g., `Campaign`, not `Campaigns`)

### Testing Standards

**Test Organization:**
- Tests MUST be in `test/` directory mirroring source structure
- LiveView tests MUST be in `test/five_apps_web/live/` directory
- Resource tests MUST be in `test/five_apps/[domain]/` directory
- Test files MUST end with `_test.exs`

**Test Quality:**
- Each test MUST have descriptive `describe` blocks and test names
- Use `setup` callbacks for common test data setup
- Use `ExUnit.Case, async: true` when tests have no shared state
- LiveView tests MUST use `Phoenix.ConnTest` and `Phoenix.LiveViewTest` helpers
- Database tests MUST use `Ecto.Adapters.SQL.Sandbox` for isolation

## Quality Gates

### Pre-Implementation Gates

**Before writing code:**
1. Feature specification MUST exist with clear user stories and acceptance criteria
2. Tests MUST be written and MUST fail (Red phase)
3. Implementation plan SHOULD be reviewed for architecture alignment

### Implementation Gates

**During development:**
1. All new code MUST have corresponding tests that pass (Green phase)
2. All existing tests MUST continue to pass (no regressions)
3. Code MUST pass `mix format --check-formatted`
4. LiveView changes MUST be tested in browser for responsiveness

### Pre-Commit Gates

**Before committing:**
1. Run `mix test` - all tests MUST pass
2. Run `mix format` - code MUST be formatted
3. Run `mix credo --strict` - critical issues MUST be resolved
4. Verify browser UI functionality for UI changes

### Pre-Merge Gates

**Before merging to main:**
1. All tests MUST pass in CI environment
2. Code review MUST be completed by at least one team member
3. Feature MUST be demonstrated working end-to-end
4. Documentation MUST be updated (CLAUDE.md, inline docs)

## Governance

### Amendment Process

This constitution may be amended when:
- New architectural patterns emerge that improve code quality
- Technology stack changes require new standards
- Team retrospectives identify gaps in current principles

**Amendment procedure:**
1. Propose amendment with rationale and examples
2. Update constitution version following semantic versioning:
   - **MAJOR**: Backward incompatible principle changes or removals
   - **MINOR**: New principles or materially expanded guidance
   - **PATCH**: Clarifications, wording improvements, non-semantic refinements
3. Update dependent templates (spec, plan, tasks) for consistency
4. Update CLAUDE.md with new guidance if applicable
5. Communicate changes to all team members

### Compliance Review

**Continuous compliance:**
- All code reviews MUST verify adherence to constitution principles
- Test suites serve as automated compliance verification for TDD
- Architecture decisions MUST be justified against constitution or documented as exceptions

**Exception handling:**
- Violations MUST be documented in implementation plan "Complexity Tracking" section
- Exception MUST include: specific violation, why needed, why simpler alternative rejected
- Repeated exceptions indicate need for constitution amendment

### Version History

This constitution supersedes all prior informal development practices and serves as the authoritative reference for development standards.

**Version**: 1.0.0 | **Ratified**: 2025-10-16 | **Last Amended**: 2025-10-16
