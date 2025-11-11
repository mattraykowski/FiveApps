# Tasks: Crew Member Leader Assignment

**Input**: Design documents from `/specs/001-as-a-player/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Constitution principle II requires TDD - all tests MUST be written FIRST and MUST FAIL before implementation.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

**Difficulty Scale**: Fibonacci sequence (1, 2, 3, 5, 8, 13, 21) where:
- **1**: Trivial (copy/paste, simple config)
- **2**: Simple (single function, basic logic)
- **3**: Moderate (multiple functions, some complexity)
- **5**: Complex (cross-module changes, business logic)
- **8**: Very complex (multiple files, integration, careful testing)
- **13**: Highly complex (architectural changes, high risk)
- **21**: Extreme complexity (avoid if possible)

## Format: `[ID] [P?] [Story] Description (Difficulty: N)`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions
- **Difficulty**: Fibonacci estimate

## Path Conventions
- **Phoenix/Elixir project**: `lib/`, `test/` at repository root
- Resource layer: `lib/five_apps/campaigns/`
- Web layer: `lib/five_apps_web/live/campaigns/`
- Tests: `test/` mirrors `lib/` structure

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and verification

- [ ] T001 Verify all existing tests pass with `mix test` (Difficulty: 1)
- [ ] T002 Verify database is up to date with `mix ash.migrate` (Difficulty: 1)
- [ ] T003 [P] Verify code formatting with `mix format --check-formatted` (Difficulty: 1)

**Checkpoint**: Development environment verified and ready

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Verify domain code interface `update_crew_member/3` exists in lib/five_apps/campaigns.ex (Difficulty: 2)
- [ ] T005 Verify domain code interface `get_crew_member!/2` exists in lib/five_apps/campaigns.ex (Difficulty: 2)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Designate Crew Member as Leader (Priority: P1) 🎯 MVP

**Goal**: Enable players to designate exactly one crew member per campaign as the leader with automatic constraint enforcement

**Independent Test**: Create campaign with crew members, designate one as leader via toggle, verify leader flag set and all others remain non-leaders. System automatically handles leader transitions.

### Tests for User Story 1 (TDD - RED PHASE) ⚠️

**NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T006 [P] [US1] Write test for is_leader attribute defaults to false in test/five_apps/campaigns/crew_member_test.exs (Difficulty: 2)
- [ ] T007 [P] [US1] Write test for is_leader can be set to true in test/five_apps/campaigns/crew_member_test.exs (Difficulty: 2)
- [ ] T008 [P] [US1] Write test for one-leader-per-campaign constraint in test/five_apps/campaigns/crew_member_test.exs (Difficulty: 3)
- [ ] T009 [P] [US1] Write test for removing leader designation in test/five_apps/campaigns/crew_member_test.exs (Difficulty: 2)
- [ ] T010 [US1] Run tests - verify all US1 tests FAIL with expected errors (Difficulty: 1)

### Implementation for User Story 1 (GREEN PHASE)

**Resource Layer Changes**:

- [ ] T011 [US1] Add is_leader boolean attribute to CrewMember resource in lib/five_apps/campaigns/crew_member.ex (Difficulty: 3)
- [ ] T012 [US1] Add :is_leader to accepted attributes in update action in lib/five_apps/campaigns/crew_member.ex (Difficulty: 2)
- [ ] T013 [US1] Generate and run dev migration with `mix ash.codegen --dev` (Difficulty: 2)
- [ ] T014 [US1] Run tests - verify T006-T007 now pass, T008 still fails (Difficulty: 1)

**Business Logic Layer**:

- [ ] T015 [US1] Create EnsureSingleLeader change module in lib/five_apps/campaigns/changes/ensure_single_leader.ex (Difficulty: 8)
- [ ] T016 [US1] Add EnsureSingleLeader change to update action in lib/five_apps/campaigns/crew_member.ex (Difficulty: 2)
- [ ] T017 [US1] Run tests - verify all US1 resource tests now pass (Difficulty: 1)

**LiveView Layer Changes**:

- [ ] T018 [P] [US1] Write LiveView test for toggle click sets leader in test/five_apps_web/live/campaigns/show_test.exs (Difficulty: 5)
- [ ] T019 [P] [US1] Write LiveView test for toggle shows success flash in test/five_apps_web/live/campaigns/show_test.exs (Difficulty: 3)
- [ ] T020 [US1] Run tests - verify US1 LiveView tests FAIL (Difficulty: 1)
- [ ] T021 [US1] Add toggle component to crew member card in lib/five_apps_web/live/campaigns/show.html.heex (Difficulty: 5)
- [ ] T022 [US1] Move class badge next to crew member name in lib/five_apps_web/live/campaigns/show.html.heex (Difficulty: 2)
- [ ] T023 [US1] Add toggle_leader event handler in lib/five_apps_web/live/campaigns/show.ex (Difficulty: 5)
- [ ] T024 [US1] Run tests - verify all US1 tests now pass (Difficulty: 1)

**Manual Testing**:

- [ ] T025 [US1] Manual test: Start dev server and verify toggle appears on crew cards (Difficulty: 2)
- [ ] T026 [US1] Manual test: Click toggle on first crew member, verify it activates (Difficulty: 2)
- [ ] T027 [US1] Manual test: Click toggle on second crew member, verify first deactivates (Difficulty: 3)
- [ ] T028 [US1] Manual test: Verify flash message shows "Leader updated" (Difficulty: 1)

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently. Players can designate and switch leaders with automatic constraint enforcement.

---

## Phase 4: User Story 2 - Visual Leader Indicator (Priority: P2)

**Goal**: Add clear visual indicators (star icon and/or badge) to show which crew member is the current leader

**Independent Test**: Set a crew member as leader using US1 functionality, verify visual indicator (star icon) appears next to their name in crew roster and disappears when leader changes.

### Tests for User Story 2 (TDD - RED PHASE) ⚠️

- [ ] T029 [P] [US2] Write LiveView test for leader shows star icon in test/five_apps_web/live/campaigns/show_test.exs (Difficulty: 3)
- [ ] T030 [P] [US2] Write LiveView test for non-leader has no star icon in test/five_apps_web/live/campaigns/show_test.exs (Difficulty: 2)
- [ ] T031 [US2] Run tests - verify all US2 tests FAIL (Difficulty: 1)

### Implementation for User Story 2 (GREEN PHASE)

- [ ] T032 [US2] Add conditional star icon next to crew member name when is_leader is true in lib/five_apps_web/live/campaigns/show.html.heex (Difficulty: 3)
- [ ] T033 [US2] Style star icon with appropriate Tailwind classes (text-warning, w-5, h-5) in lib/five_apps_web/live/campaigns/show.html.heex (Difficulty: 2)
- [ ] T034 [US2] Run tests - verify all US2 tests now pass (Difficulty: 1)

**Manual Testing**:

- [ ] T035 [US2] Manual test: Designate crew member as leader, verify star icon appears (Difficulty: 2)
- [ ] T036 [US2] Manual test: Switch leader to different crew member, verify star moves (Difficulty: 2)
- [ ] T037 [US2] Manual test: Remove leader, verify no star icon shows (Difficulty: 2)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently. Visual indicators clearly show leader status.

---

## Phase 5: User Story 3 - Remove Leader Designation (Priority: P3)

**Goal**: Allow players to explicitly remove leader designation without assigning a new leader (toggle off)

**Independent Test**: Set a crew member as leader, click their toggle to turn it off, verify no crew member has leader flag and no visual indicators show.

### Tests for User Story 3 (TDD - RED PHASE) ⚠️

- [ ] T038 [P] [US3] Write test for toggling leader off sets is_leader to false in test/five_apps/campaigns/crew_member_test.exs (Difficulty: 2)
- [ ] T039 [P] [US3] Write LiveView test for clicking toggle off removes leader in test/five_apps_web/live/campaigns/show_test.exs (Difficulty: 3)
- [ ] T040 [US3] Run tests - verify US3 tests FAIL or PASS (may already work from US1) (Difficulty: 1)

### Implementation for User Story 3 (GREEN PHASE)

- [ ] T041 [US3] Verify toggle can be clicked off (set is_leader to false) - implementation likely already complete from T023 (Difficulty: 1)
- [ ] T042 [US3] Run tests - verify all US3 tests pass (Difficulty: 1)

**Manual Testing**:

- [ ] T043 [US3] Manual test: Set crew member as leader, click toggle off, verify no leader remains (Difficulty: 2)
- [ ] T044 [US3] Manual test: Remove leader, set new leader, verify system allows it (Difficulty: 2)

**Checkpoint**: All user stories should now be independently functional. Full feature set complete.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final improvements, production migration, and comprehensive validation

**Final Migration**:

- [ ] T045 Squash dev migrations with `mix ash.codegen add_leader_to_crew_members` (Difficulty: 3)
- [ ] T046 Verify generated migration has proper up and down functions in priv/repo/migrations/ (Difficulty: 2)
- [ ] T047 Test migration rollback with `mix ecto.rollback` (Difficulty: 2)
- [ ] T048 Re-run migration with `mix ecto.migrate` (Difficulty: 1)

**Code Quality**:

- [ ] T049 [P] Run `mix format` on all modified files (Difficulty: 1)
- [ ] T050 [P] Run `mix credo --strict` and resolve any issues (Difficulty: 3)
- [ ] T051 [P] Verify all tests pass with `mix test` (Difficulty: 1)

**Accessibility & UX**:

- [ ] T052 [P] Verify toggle has proper aria-label in lib/five_apps_web/live/campaigns/show.html.heex (Difficulty: 1)
- [ ] T053 [P] Test keyboard navigation (Tab to toggle, Space/Enter to activate) (Difficulty: 2)
- [ ] T054 [P] Verify responsive layout on tablet viewport (768px) (Difficulty: 2)

**Edge Case Testing**:

- [ ] T055 Manual test: Delete current leader crew member, verify no error and no leader remains (Difficulty: 3)
- [ ] T056 Manual test: Rapid toggle clicks on different crew members, verify consistent final state (Difficulty: 3)
- [ ] T057 Manual test: Toggle same crew member twice (on then off), verify idempotent behavior (Difficulty: 2)

**Documentation**:

- [ ] T058 [P] Update CLAUDE.md with leader designation feature notes if needed (Difficulty: 2)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - User Story 1 (P1): Can start after Foundational - No dependencies on other stories
  - User Story 2 (P2): Depends on User Story 1 (uses toggle from US1) - Should wait for US1
  - User Story 3 (P3): Depends on User Story 1 (tests remove functionality) - Should wait for US1
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - **INDEPENDENT** (MVP)
- **User Story 2 (P2)**: Should start after User Story 1 - Enhances US1 with visual indicators
- **User Story 3 (P3)**: Should start after User Story 1 - Tests edge case of US1 functionality

**Note**: US2 and US3 both depend on US1, but could potentially be done in parallel by different developers after US1 is complete.

### Within Each User Story

- Tests (RED phase) MUST be written and FAIL before implementation (GREEN phase)
- Resource layer before web layer
- Attribute before business logic (EnsureSingleLeader)
- Business logic before UI components
- UI components before event handlers
- Manual testing after automated tests pass

### Parallel Opportunities

**Setup Phase**:
- T001, T002, T003 can all run in parallel (independent checks)

**Foundational Phase**:
- T004, T005 can run in parallel (independent verifications)

**User Story 1 - Tests** (within RED phase):
- T006, T007, T008, T009 can run in parallel (different test cases in same file)

**User Story 1 - LiveView Tests**:
- T018, T019 can run in parallel (different test scenarios)

**User Story 2 - Tests**:
- T029, T030 can run in parallel (different test scenarios)

**User Story 3 - Tests**:
- T038, T039 can run in parallel (different test layers)

**Polish Phase**:
- T049, T050, T051, T052, T053, T054, T058 can all run in parallel (independent quality checks)

---

## Parallel Example: User Story 1

```bash
# Launch all test writing tasks for User Story 1 together:
Task T006: "Write test for is_leader attribute defaults to false"
Task T007: "Write test for is_leader can be set to true"
Task T008: "Write test for one-leader-per-campaign constraint"
Task T009: "Write test for removing leader designation"

# After tests fail (T010), launch resource layer tasks:
Task T011: "Add is_leader boolean attribute to CrewMember"
Task T012: "Add :is_leader to update action accepted attributes"
# Then T013-T014 sequentially (migration and test verification)

# After constraint test still fails, add business logic:
Task T015: "Create EnsureSingleLeader change module"
Task T016: "Add change to update action"
# Then T017 (verify tests pass)

# Launch LiveView test writing together:
Task T018: "Write test for toggle click sets leader"
Task T019: "Write test for toggle shows success flash"
# Then T020 (verify tests fail)

# Implement UI changes:
Task T021: "Add toggle to crew card"
Task T022: "Move class badge"
Task T023: "Add toggle_leader event handler"
# Then T024 (verify tests pass)

# Manual testing can be done in parallel:
Task T025, T026, T027, T028 (all independent browser checks)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (TDD: tests → implementation → manual test)
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Complete Phase 6: Polish (migration, quality, docs)
6. Deploy/demo if ready

**Estimated Time**: ~2-3 hours (MVP only)

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP! 🎯)
3. Add User Story 2 → Test independently → Deploy/Demo (Enhanced visuals)
4. Add User Story 3 → Test independently → Deploy/Demo (Edge cases handled)
5. Each story adds value without breaking previous stories

**Estimated Time**: ~3-4 hours (full feature)

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together (~15 min)
2. Once Foundational is done:
   - Developer A: User Story 1 (~2 hours)
3. Once US1 is done:
   - Developer B: User Story 2 (~1 hour)
   - Developer C: User Story 3 (~30 min)
4. Stories complete and integrate independently

---

## Task Complexity Summary

### By Difficulty (Fibonacci)

| Difficulty | Task Count | Total Points | Tasks |
|------------|------------|--------------|-------|
| 1 | 17 | 17 | T001, T002, T003, T010, T014, T017, T020, T024, T028, T031, T034, T040, T041, T042, T048, T051, T052 |
| 2 | 24 | 48 | T004, T005, T006, T007, T009, T012, T013, T016, T022, T025, T026, T030, T033, T035, T036, T037, T038, T043, T044, T046, T047, T053, T054, T057, T058 |
| 3 | 12 | 36 | T008, T011, T019, T027, T029, T032, T039, T045, T050, T055, T056 |
| 5 | 5 | 25 | T018, T021, T023 |
| 8 | 1 | 8 | T015 |
| **Total** | **59** | **134** | |

**Complexity Notes**:
- Most tasks are simple (1-3 difficulty) due to clear design and TDD approach
- Highest complexity task (8): EnsureSingleLeader change module (requires Ash framework knowledge and business logic)
- Medium complexity (5): LiveView integration tasks (UI + event handling + state management)

### By Phase

| Phase | Task Count | Total Points | Avg Difficulty |
|-------|------------|--------------|----------------|
| Phase 1: Setup | 3 | 3 | 1.0 |
| Phase 2: Foundational | 2 | 4 | 2.0 |
| Phase 3: User Story 1 | 23 | 58 | 2.5 |
| Phase 4: User Story 2 | 9 | 21 | 2.3 |
| Phase 5: User Story 3 | 7 | 12 | 1.7 |
| Phase 6: Polish | 15 | 36 | 2.4 |

**Phase Insights**:
- User Story 1 has highest complexity (core functionality + custom change logic)
- User Story 3 is simplest (mostly verification of existing functionality)
- Polish phase has good parallelization opportunities (15 tasks, most can run together)

### Critical Path (Sequential Dependencies)

**Minimum sequential tasks** (cannot parallelize):

1. T001-T003 → T004-T005 (Setup → Foundational)
2. T006-T010 (Write tests → Verify fail)
3. T011-T014 (Add attribute → Verify partial pass)
4. T015-T017 (Add business logic → Verify full pass)
5. T018-T020 (Write UI tests → Verify fail)
6. T021-T024 (Implement UI → Verify pass)
7. T045-T048 (Squash migration → Test rollback → Re-apply)

**Critical path**: ~23 sequential tasks out of 59 total (39% must be sequential, 61% can parallelize)

---

## Notes

- [P] tasks = different files, no dependencies on previous incomplete tasks
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- **TDD discipline**: Verify tests FAIL before implementing (T010, T020, T031, T040)
- Commit after each test pass milestone (T017, T024, T034, T042)
- Stop at any checkpoint to validate story independently
- Manual testing validates real-world usability beyond automated tests
- Difficulty estimates help with planning but should be updated based on actual experience
- Fibonacci scale emphasizes that larger tasks have more uncertainty and should be broken down if >8

## Success Criteria

✅ All tasks complete when:
- All automated tests pass (ExUnit resource + LiveView tests)
- All manual tests pass (browser interaction, edge cases)
- Code quality checks pass (format, credo)
- Migration is reversible and tested
- Accessibility requirements met (ARIA, keyboard nav, responsive)
- All three user stories independently functional
- Constitution principles followed (TDD, domain interfaces, accessibility)

**Total Estimated Effort**: 134 Fibonacci points (~3-4 hours actual time for experienced developer)
