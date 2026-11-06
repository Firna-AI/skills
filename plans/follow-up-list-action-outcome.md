# Show the Action outcome in the follow-up list

Status: Active. On branch `calummoore/follow-up-list-pending-choices`, no pull request yet. The pull request that completes the work deletes this plan, as the `plans` skill says.

`follow-ups.sh` of the `plans` skill lists the open follow-up items. Each
line ends with the kind of the item. The **Action** line of the item says
what the item waits for, and the script does not read it. An item of the
kind Outside the scope can wait for the user or not, and the list shows
the same tag for both. The change makes the listing print the outcome of
the **Action** line beside the kind, as `[Outside the scope | ask the user]`.

The user chose this approach, B of decision 1, on 2026-11-03. The options
check of the same day added F, which also lets a post-merge task that
waits for the user carry an **Action** line. The user chose B again on
2026-11-06, and that answer approves this plan.

The change does not change the kind, the template, or an item, and it
needs no migration. A post-merge task that waits for the user still lists
without an outcome, as B says. The change adds no count of the waiting
items. The branch starts from
`calummoore/follow-up-dependencies`, the branch of PR #85. That pull
request changes the same lines of the script, its tests, and the
reference.

Contract owners:

- [Follow-up items](../skills/plans/references/follow-up-items.md), the
  section "Listing the items".

The plan has no list of replaced ways. The change adds the outcome to the
line of an item and replaces nothing.

## Decision 1: Follow-up list hides pending user choices

- **Answer:** B, chosen by the user on 2026-11-03, and chosen again on 2026-11-06 after the options check added F.
- **Severity:** Medium. **Effort:** Small.
- **Source:** Review of PR #247 in `mokly-ai/mokly`. Record: `plans/follow-ups/follow-up-list-approval-state.md` in that repository.
- **Category:** Process.
- **Location:** `skills/plans/scripts/follow-ups.sh:73-105`, the reader of each item and the line that it prints. `skills/plans/references/follow-up-items.md:196-202`, "Listing the items". `skills/plans/templates/follow-up.md`, the layout of a post-merge task. `tests/follow_ups_test.sh`.
- **Terms:**
  - **Kind:** the second line of an item, with four values. Outside the scope and Post-merge task name an origin. Fix after merge and Needs decision name a state.
  - **Action:** the last line of an item. Its outcome is the words before the first comma: `ask the user` or `fix after merge`.
  - **Top-level line:** a line that starts with `- **Action:**` at the left margin. An indented list entry in the item is not a top-level line.
- **Background:**
  - The script reads the grades, the title, the kind, and the link lines. It never reads the **Action** line.
  - Commit `f846559` of PR #47 gave an item outside the review scope the full layout with an **Action** line, on 2026-10-29. Its kind stayed Outside the scope.
  - On 2026-11-03, the 378 items of six repositories were read. Every Needs decision item ends with `ask the user`. Every Fix after merge item ends with `fix after merge`. No Post-merge task has an **Action** line.
  - Outside the scope splits: 34 items end with `ask the user`, and 82 end with `fix after merge`. The 34 are 25 in `mokly-ai/mokly`, 4 in `futex-ai/ai`, and 2 in this repository. `mokly-ai/mokly-cloud`, `futex-ai/ui`, and `futex-ai/accounting` have one each.
  - All 324 **Action** lines start with one of the two outcomes. One item has an indented **Terms** entry with the same label above its **Action** line.
  - Three post-merge tasks in `mokly-ai/mokly-cloud` cannot start before the owner answers. Their **Needs** or **Task** lines say so.
- **Problem:** The list shows `[Outside the scope]` for an item that waits for the user and for an item that an agent fixes without the user. It shows `[Post-merge task]` also for a task that waits for the user. A reader cannot find the waiting items in the list.
- **Impact if no action:** A reader who scans for Needs decision misses 34 of the 179 waiting items with an **Action** line, and each waiting post-merge task. Decisions then stay open longer, or an agent starts work that waits for the user.
- **Root question:** How can a reader of the follow-up list see which items wait for the user's choice?
- **Options:**
  - **A.** Keep the current list. Readers open each item and read its **Action**. Effort: Small.
  - **B.** Make the script print the outcome beside the kind, for example `[Outside the scope | ask the user]`. It reads only the top-level **Action** line. An item without one, such as a post-merge task, shows only its kind. No item changes. Add a test, and update "Listing the items". The existing tests keep passing, because their items have no **Action** line. The list then depends on the fixed words of the two outcomes. Effort: Small.
  - **C.** Give every `ask the user` item the kind Needs decision, and keep the origin in the **Added** line. Change the words of the template and the reference to match. Re-mark 34 items in six repositories. The kind still repeats the **Action**, so the two can disagree again. Effort: Small.
  - **D.** Replace the kind with two fields, Origin and Approval state. Migrate every repository that uses the skill. The new field repeats the **Action**. Effort: Large.
  - **E.** Drop the kind. The script prints only the outcome, or Post-merge task for an item without an **Action** line. The origin stays in the **Added** line. Each rule that names a kind changes. The script ignores the kind line of an old item, so no migration is needed. An item that lost its **Action** line then lists as a post-merge task. Effort: Medium.
  - **F.** Do B. Also let a post-merge task that cannot start before the user answers end with `- **Action:** ask the user, because <reason>`. The template and "Writing an item" say so. "Working on an item" says that the answer removes the line. B then shows `[Post-merge task | ask the user]`, and the waiting rule of "Working on an item" covers the task. The user adds the line by hand to the three tasks in `mokly-ai/mokly-cloud`. Each writer must judge when a task waits. Effort: Small.
- **Left out:**
  - A flag that lists only the waiting items. The default list then still hides the state, so it fails the goal.
  - A hand-kept index of the waiting items. It goes stale.
  - A check that fails a mismatch of the kind and the **Action**. It shows no waiting item, so it fails the goal. The `testing` skill also gives plans no test.
  - A folder for the waiting items. It needs a migration in six repositories. An answer that defers the work moves the file and breaks each path that names it.
  - The waiting items in a first block. It breaks the score order that the user chose on 2026-10-30. Almost half of all items wait, so the block helps little.
  - B's reader also reads the **Needs** line of a task. That line is free prose without fixed words, so the reader would guess.
  - The question of a waiting task in its own Needs decision item, which the task names on its **Depends on** line. For work with one open question, "Work with more than one open question" writes one item, not two.
- **Wider fix:** F. B covers only the items with an **Action** line. F makes that line the mark of a waiting item of every kind.
- **Previous examples:**
  - In this repository, `plans/follow-ups/closed-item-place-beside-open-items.md` and `plans/follow-ups/install-replaces-foreign-symlinks.md` wait for the user. The list shows both as `[Outside the scope]`.
  - The `mokly-ai/mokly` migration in commit `0ee5e459` moved 145 items. The list showed none of its 29 Outside the scope items with `ask the user` as waiting.
  - In `mokly-ai/mokly-cloud`, `stripe-tax-registrations-not-added.md`, `closed-pr87-records-need-reconciliation.md`, and `preview-app-secrets-not-rotated.md` wait for the owner. The list shows each as `[Post-merge task]`.
- **Related:**
  - PR #85, on the branch `calummoore/follow-up-dependencies`, changes the same lines of the script, its tests, and the reference. Its rule in "Working on an item" says that an item waits for the user when its kind is Needs decision or its **Action** line says `ask the user`. B shows both facts on each line.
  - `plans/follow-ups/follow-up-list-hides-item-choices.md` in `mokly-ai/mokly-cloud` proposes the same B. Its other two parts are separate questions.
- **Recommendation:** F, first B. F keeps all of B and adds one writing rule at the same Small effort, so the list also shows a post-merge task that waits for the user. E also removes the kind, which can go stale, but alone it lists a waiting task as a post-merge task.
- **Action:** ask the user, because F adds a field to the layout of a post-merge task in every repository, and the user chose B before the check added F.

The options share these assumptions:

- The **Action** line holds the outcome of each item that has one.
  Source: `skills/decisions-and-findings/references/outcomes.md`. Kept,
  because all 324 surveyed lines start with an outcome.
- A post-merge task never waits for the user. Source: the template, whose
  task layout has no **Action** line. The reason fails for three tasks in
  `mokly-ai/mokly-cloud`. F drops it.
- The list keeps one line for each item, in score order. Source: the user
  decision of 2026-10-30. Kept.
- Each item is one Markdown file that bash and POSIX `awk` read. Source:
  the user decision of 2026-10-29 and the macOS rule of `AGENTS.md`. Kept.

The options check of 2026-11-03 added F and changed the recommendation
from B to F. Report: `.context/follow-up-list-action-outcome/options-check.md`.

## Design

Each line below is my design call, of 2026-11-03.

The line of an item:

- The reader takes the last line of the item that starts with
  `- **Action:** ` at the left margin. An indented line does not count,
  and neither does a line without the leading `- `. The layout puts the
  **Action** line last, so an example line earlier in the body cannot
  win. Each real item has one such line.
- The outcome is the text after the label, up to the first comma or
  period, without the spaces around it.
- The line ends with `[<kind> | <outcome>]`. An item without an outcome
  ends with `[<kind>]`, as before. A missing kind still shows `No kind`.
- The line shows both parts also when they repeat one fact, as
  `[Fix after merge | fix after merge]` does for 208 of the 378 items. One
  rule then holds for every line, a reader finds each waiting item by
  `ask the user`, and a stale kind shows.
- The outcome does not change the score, the order, the `?` mark, the
  link lines, or the count line.
- The listing adds no count of the waiting items. B has none, and no rule
  reads one. `plans/follow-ups/after-merge-reminder-omits-waiting-items.md`
  holds that question.

The scope:

- No item of this repository changes. Each **Action** line of the six
  repositories already has the form that the reader takes.
- "Working on an item" already defines a waiting item from the kind and
  the **Action** line, since PR #85. `README.md` does not describe the
  listing.
- The plan adds no task for the records in the mokly repositories. The
  pull request description and the report after the merge name them,
  because the user changes the items of other repositories by hand, as
  the follow-up links plan of PR #85 records on 2026-11-03.
- The branch builds on `calummoore/follow-up-dependencies` while PR #85
  is open, because both change the same lines. The pull request targets
  that branch, as a stack, until PR #85 merges.

The script and the test:

- `follow-ups.sh` stays one file, in POSIX `awk` and bash 3.2, which
  macOS has. The `awk` pass for each item also reads the outcome.
- One new test in `tests/follow_ups_test.sh`,
  `test_shows_the_action_outcome_beside_the_kind`, with three items:
  - an Outside the scope item with `ask the user`,
  - an Outside the scope item with `fix after merge`, whose indented
    **Terms** entry with the same label comes first,
  - a post-merge task without an **Action** line.
- The test asserts the exact listing. It fails when the script ignores
  the **Action** line, reads the indented entry, or adds a bar to an item
  without the line. The existing tests of the exact output prove that an
  item without the line lists as before.

## Milestone 1: Documentation

Depends on: none

The `docs implementor` states the new line in the reference. The script
follows in Milestone 2.

- [x] `skills/plans/references/follow-up-items.md`, "Listing the items":
      each line also gives the outcome of the top-level **Action** line
      after the kind, as `[Outside the scope | ask the user]`. An item
      without that line shows only its kind.
- [x] Walk the survey cases of
      `.context/follow-up-list-pending-choices/brainstorm.md` with the new
      text, as the `writing-skills` skill says. Save the walk under
      `.context/follow-up-list-action-outcome/`.
- [x] Run `scripts/check.sh` and the trailing-whitespace check.

Walk: `.context/follow-up-list-action-outcome/m1-walk.md`.

## Milestone 2: The listing

Depends on: 1

The `non-ui implementor` makes `follow-ups.sh` print the outcome.

- [x] Add the test of the design to `tests/follow_ups_test.sh`. Run it
      against the current script, and see it fail on an assertion.
- [x] Change `skills/plans/scripts/follow-ups.sh` and its header comment,
      as the design says.
- [x] Run `bash tests/follow_ups_test.sh` with gawk, with `gawk --posix`,
      and with mawk or the BWK `awk` when one is available. Name each
      `awk` that could not run. Save the output under
      `.context/follow-up-list-action-outcome/`.
- [x] Smoke test: run the script over the items of this repository and of
      `.context/follow-up-list-pending-choices/repos/`. Compare the output
      with the listings in `.context/follow-up-list-action-outcome/baseline/`.
      Check that 180 lines show `ask the user`: the 179 of the survey and
      `plans/follow-ups/after-merge-reminder-omits-waiting-items.md`, which
      this branch adds. Check that only the tag changed. Save the output in
      the same folder.
- [x] Run `scripts/check.sh` and `shellcheck` on the changed scripts.

Evidence: `.context/follow-up-list-action-outcome/`: `m2-test-before.txt`, `m2-tests-gawk.txt`, `m2-tests-gawk-posix.txt`, `m2-run-all.txt`, `m2-new-test.json`, `m2-smoke/`, `m2-check.txt`, `m2-shellcheck.txt`, `m2-awk-availability.txt`.

## Milestone 3: Verification, commit, review, and pull request

Depends on: 1, 2

The orchestrator runs the gate, the review, and the pull request.

- [ ] Run the targeted tests and the complete gate named in `AGENTS.md`.
- [ ] Commit with Conventional Commits and push the branch. Watch CI as the
      `finish-work` skill says.
- [ ] Review the diff of this change with the `implementation-review`
      skill after the push. Its base is `origin/calummoore/follow-up-dependencies`
      while PR #85 is open, and `origin/main` after it merges. Report the
      findings, then apply the fix rule: fix the `fix now` findings,
      record follow-up items under `plans/follow-ups/` for the rest,
      re-review once, and report.
- [ ] Delete this plan when the `plans` skill says, under "Deleting the
      plan".
- [ ] Open the pull request. Its description gives the decision and the
      design calls of this plan with their dates, a permalink to this plan,
      the follow-up items that the change adds, and the records in the
      mokly repositories. It says that an existing install gets the change
      when `update.sh` or `install.sh` runs there. Then watch CI as the
      `finish-work` skill says.
