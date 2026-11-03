# Order and same-branch links for follow-up items

Status: Active. On branch `calummoore/follow-up-dependencies`, no pull request yet. The pull request that completes the work deletes this plan, as the `plans` skill says.

The `plans` skill keeps each follow-up item as one file under
`plans/follow-ups/`. `follow-ups.sh` lists the open items by priority score,
and an agent takes "the next item" in that order. An item can say in its
**Related** line that it needs another item first, or that one branch can fix
it together with another item. That line is prose. The script does not read
it, and the rule for the next item ignores it.

The change adds two optional lines to the first lines of an item: **Depends
on** and **Do with**. `follow-ups.sh` prints the links under each item, and
the rules for the next item use them. The score and the order do not change.

The user adds the lines to the items of other repositories by hand. Open items
there propose to print the outcome of the **Action** line beside the kind:
`follow-up-list-approval-state.md` in `mokly-ai/mokly` and
`follow-up-list-hides-item-choices.md` in `mokly-ai/mokly-cloud`. This plan
does not change the line of an item, so it does not conflict with them.

The user answered both decisions on 2026-11-03 and asked for no change, so I
took the answers as the approval of the plan.

Contract owners:

- [Follow-up items](../skills/plans/references/follow-up-items.md), the rules
  of the `plans` skill for follow-up items.
- [The follow-up template](../skills/plans/templates/follow-up.md), the layout
  of an item.

## Decision 1: Follow-up list ignores order and same-branch links

- **Answer:** B, chosen by the user on 2026-11-03, and chosen again on the same day after the options check added E and F.
- **Severity:** Medium. **Effort:** Medium.
- **Source:** Design.
- **Category:** Process.
- **Location:** `skills/plans/scripts/follow-ups.sh`. `skills/plans/references/follow-up-items.md`, the sections "Writing an item", "Working on an item", and "Listing the items". `skills/plans/templates/follow-up.md`. `tests/follow_ups_test.sh`.
- **Terms:**
  - **Priority score:** a number from 0 to 10 that `follow-ups.sh` adds up from the grades on the first line of an item.
  - **Related line:** the optional `**Related:**` field of an item. It names the linked items and says in prose what each link means.
  - **Parent item:** an item that holds work with open questions. Each question has its own decision item, and the parent item waits for the answers.
- **Background:**
  - The only order rule for items is that no agent starts a parent item while one of its decision items is open.
  - A plan milestone has a `Depends on:` line. The `delegating` skill starts a milestone only after each milestone on that line merged. Items have no such line.
- **Problem:** The listing orders items by score only, and the rule for the next item does not read the **Related** line. In `mokly-ai/mokly`, `cloud-gzip-listing-rollout.md` needs `cloud-gzip-decoder-rollout.md` first, and only the sort order of the file names lists the decoder first.
- **Impact if no action:** An agent can start an item before the item that it needs. It can also fix two items that change the same code in two branches. To see the links, a reader opens each of up to 176 items.
- **Root question:** How do the follow-up items show the order of the work and the items to fix together?
- **Options:**
  - **A.** Rules only. Each link in the **Related** line starts with its kind, "Depends on" or "Do with", and the item file. The rule for the next item reads these links. `follow-ups.sh` does not change, so a reader still opens each item to see the order. Effort: Small.
  - **B.** Add two optional lines to the first lines of an item. **Depends on** names the items to fix first. **Do with** names the items for the same branch. `follow-ups.sh` prints the open linked items under each item and keeps the score order. The rule for the next item fixes the **Depends on** items first and takes the **Do with** items into the same branch. Effort: Medium.
  - **C.** Do B, and make `follow-ups.sh` list the items in work order. Each item lists directly before the items that need it. Each **Do with** group lists as one block, at the place of its highest score. The score column then does not fall from top to bottom. This changes the score order that the user chose on 2026-10-30. Effort: Medium.
  - **D.** Named batches. An optional **Batch** line gives a shared name, and **Depends on** names an item or a batch. `follow-ups.sh` lists each batch as one block. A batch keeps its name when one member is fixed alone. Two branches can give one group two different names. Effort: Medium.
  - **E.** Do B. Each item that other open items depend on also takes the highest score of those items, and lists directly before them, with its own score beside it. The score column still falls from top to bottom. About ten items then show a score that does not come from their own grades, and a chain of links needs a pass that repeats. This changes the order of 2026-10-30 for those items. Effort: Medium.
  - **F.** Do B, and add a flag that prints the order of C. The default listing keeps the score order. It costs the work of C and a second mode, and the rule for the next item must say which order it follows. Effort: Medium.
- **Left out:**
  - Change nothing. The listing and the rule for the next item ignore the prose links, so it fails the goal.
  - Links that the script finds alone, from the names in **Related** and from the paths that two items share. It cannot tell which item goes first. Shared paths such as `README.md` give false links, and chains of **Related** links join up to 15 items.
  - One shared order file. Every branch would edit it, and the user chose one file per item on 2026-10-29 to stop such conflicts.
  - GitHub issues with "blocked by" links. It replaces the item files that the user asked to extend.
- **Wider fix:** C. The list itself gives the work order, so no reader has to apply the links.
- **Previous examples:**
  - Commit `8748b7b`, 2026-11-01: parent items and decision items, with the one order rule that items have today.
  - Commit `53aad7c`, 2026-10-30: the listing by priority score.
  - The `Depends on:` line of plan milestones, in `skills/plans/templates/plan.md`.
  - In `mokly-ai/mokly`, `cloud-gzip-decoder-rollout.md` says that one pin of release 0.17.0 serves it and two other items.
- **Recommendation:** B. It shows each link beside its item and keeps the score order of 2026-10-30, which suits links on about one item in ten. C best protects the order, because the list becomes the work order, and it can come later on the same lines. The options check of 2026-11-03 added E and F and kept B. E gives a list in work order for the order links at a lower cost than C.
- **Action:** ask the user, because B and C trade a list by score against a list in work order, and the brainstorm gives the user the choice of the approach.

The options share these assumptions:

- The links live in the item files. Source: the request and the `plans`
  skill. GitHub issues drop it.
- One file per item. Source: the user decision of 2026-10-29. The shared
  order file drops it.
- An item scores from its own grades only. Source: the score of 2026-10-30,
  whose weights were design calls. E drops it.
- A writer records each link. Source: `references/follow-up-items.md`. The
  links that the script finds alone drop it.
- Each link is optional. Source: the request.
- The change edits only this repository. Source: my design call of
  2026-11-02. Decision 2 keeps it.

## Decision 2: Existing links stay prose in other repositories

- **Answer:** the user does the migration by hand, on 2026-11-03: "I will do the migration manually don't worry about it". The plan adds no task and no rule for it. This is closest to A.
- **Severity:** Medium. **Effort:** Small.
- **Source:** Design.
- **Category:** Process.
- **Location:** None in this repository. The items are under `plans/follow-ups/` in `mokly-ai/mokly`, `mokly-ai/mokly-cloud`, `futex-ai/ai`, `futex-ai/ui`, and `futex-ai/accounting`.
- **Background:**
  - Five other repositories hold 354 items. The three items of this repository have no **Related** line. Decision 1 edits only this repository.
  - In the two mokly repositories, about 10 prose links give an order, and about 21 items name another item for the same branch.
  - In `futex-ai/ai` and `futex-ai/ui`, 8 of 12 items have prose links. `futex-ai/ui` holds a parent item, `scroll-lock-moves-fixed-elements.md`.
- **Problem:** After the merge, no item in any repository has the new lines, so the listing shows no link. An old item gets the lines only when an agent edits it for another reason.
- **Impact if no action:** The listings of the other repositories show no order for a long time. An agent can still take `mokly-cloud-index-v9.md` at 8/10 before `release-detail-content-ids.md` at 5/10, the release that it needs.
- **Root question:** How do the links that existing items state only in prose come to guide the listing and the next item, in each repository that holds items?
- **Options:**
  - **A.** No migration. An agent adds the lines when it next edits an item. Effort: Small.
  - **B.** Add a post-merge task to this plan. After the merge, one branch in each repository that holds items adds the lines from the prose links of its items. When the plan is deleted, the task becomes a follow-up item of this repository, and it starts when the user asks for it. Effort: Small.
  - **C.** Do the migration now, in one Conductor workspace for each repository that holds items. Each workspace starts from `main` of its repository and runs the gate and the review of its `AGENTS.md`. Each branch merges after this change merges, as post-merge work. Effort: Medium.
  - **D.** Do B, and add a rule for the time before the migration. The agent that takes an item reads its **Related** line, and searches `plans/follow-ups/` for the file name of the item. It follows each order or same-branch link that an item without the lines states in prose. Every repository gets the rule with the skill update. The rule reads the old form, so it needs an end time, as "Consumers outside the repository" in `references/replacing-an-old-way.md` asks. Effort: Small.
  - **E.** Put the migration task in each repository that holds items, as one post-merge task item there, instead of one item in this repository. Each listing then shows the task beside the items that it changes. It needs a branch and a pull request now in each of five other repositories. Effort: Medium.
  - **F.** Do B, and add one step to "Repository steps" in `skills/writing-skills/SKILL.md`. The step says that a change of a field of a record that other repositories hold, such as a follow-up item, records a post-merge task for each such repository. Effort: Small.
- **Left out:**
  - A script that writes the lines from the prose. A wrong direction or a false **Do with** link misleads the next item more than no link does, so it fails the goal.
  - A listing note that counts the items with names in **Related** and no link lines. Most **Related** lines hold no order or same-branch link, so the note never clears, and it fails the goal.
  - A trigger for old items in the `plans` description. D reaches the same moment through the reference without a context cost on every turn, so D is better on every point.
  - A migration inside this pull request. Only a branch of each repository can change its items.
- **Wider fix:** F. The class is a change of a shared layout that leaves the records of other repositories behind, and F applies also to the next such change.
- **Previous examples:**
  - Commit `53aad7c` added two grades on 2026-10-30. Branches that the user started brought the mokly items to the new grades: `mokly-ai/mokly-cloud` PR #83 on 2026-10-31, and `mokly-ai/mokly` PR #260 on 2026-11-01.
  - `futex-ai/ui` keeps `adopt-web-modal-stack-in-accounting.md`, a task for work in `futex-ai/accounting`.
- **Recommendation:** B. It records the work so that it is not lost, and the user starts the branches in other repositories, as after the grades of 2026-10-30. F best protects the codebase, because it also covers the next change of a shared layout.
- **Action:** ask the user, because B and C trade a later migration against links at the merge, and C and E open branches in five other repositories. D and F add work to Milestone 1, so Milestone 1 starts after the answer.

The options share these assumptions:

- A branch of each repository changes its items. Source: decision 1 and the
  user decision of 2026-10-29.
- An agent, not a script, gives the kind and the direction of each link.
  Source: the **Left out** lines of both decisions.
- The work in other repositories starts after this change merges. Source:
  the completion boundary of the `plans` skill.
- Until an item has the lines, the next item ignores its prose links.
  Source: my design calls of 2026-11-02. D drops it.
- Each change of a shared layout decides its migration again. Source: the
  earlier layout changes. F drops it.

The options check of 2026-11-03 added D, E, and F, and kept B.

## Design

Each line below is my design call, with its date.

The lines of an item:

- 2026-11-02: The lines are `- **Depends on:**` and `- **Do with:**`.
  **Depends on** is the word of the milestone line. **Related** keeps its
  wider meaning.
- 2026-11-02: Both lines are optional and come after **Reason**. Each line
  holds only item names. The **Related** line still says what each link
  means.
- 2026-11-03: A line names each item by its path,
  `plans/follow-ups/<name>.md`, as "Writing an item" asks for every
  follow-up item. The script reads the last part of each name, so a bare
  file name or a Markdown link also works.
- 2026-11-03: A link line can wrap. The script reads the line of the label
  and each indented line after it, up to the next list item or blank line.
  143 of the 165 items of `mokly-ai/mokly` wrap their first lines.
- 2026-11-03, Milestone 1: Commas separate the names. A long line wraps onto
  indented lines, not into a list. The script still reads an indented list,
  so that the reader is lenient.
- 2026-11-03, review round 1: The script reads link lines only in the first
  list of an item, so a label in the body adds no link. A bold label ends a
  field, a repeated link line joins, and a Markdown link counts by its target.
- 2026-11-03: The plan has no list of replaced ways. **Related** keeps the
  meaning of each link, and an item without the lines stays valid.

The listing:

- 2026-11-02: A name that matches no open item counts as fixed. The listing
  prints it on a `no such item` line and still exits 0. The `git-commit`
  skill already asks the branch that deletes an item to update each
  reference to it.
- 2026-11-03: The listing shows a **Depends on** link also on the needed
  item, as `needed by`. A `do with` line names the whole group: every open
  item that a chain of **Do with** links reaches, in both directions.
- 2026-11-03: Under the line of an item, the listing prints up to four lines,
  in this order: `depends on:`, `needed by:`, `do with:`, and
  `no such item:`. It prints a line only when the line has a name. Each line
  gives the bare file names in C-locale order, separated by ", ". The lines
  start at the column of the path.
- 2026-11-03: The links do not change the score, the order, the `?` mark, or
  the count line. An item without links lists as before.
- 2026-11-03: A link from an item to itself is ignored.

"Listing the items" in the reference shows the gzip example.

The rules:

- 2026-11-02: A parent item names its open decision items on its
  **Depends on** line. One rule then covers every wait.
- 2026-11-02: When an agent takes the next item, it fixes each open item on
  the **Depends on** line first, or in the same branch. The open items of the
  **Do with** group go into the same branch. From Milestone 1, the rules
  apply again to each item that joins, so that a chain is followed.
- 2026-11-03: An item waits for the user when its kind is Needs decision or
  its **Action** line says `ask the user`, as 26 Outside the scope items of
  the mokly repositories do. The agent gives it to the user and does not
  start the items that depend on it. It still fixes the rest of a **Do with**
  group, because an open item blocks only dependent work. From Milestone 1,
  all such items go to the user in one message, and "an item that waits for
  the user" replaces "an item that needs a decision" in the reference.
- 2026-11-03: When the user names one item, the agent names all items that
  the rules for the next item add, and takes them only when the user asks,
  because only the user starts work on an item. The named item starts
  only after its **Depends on** items are fixed or join the branch.
- 2026-11-03: Two items that depend on each other go into one branch.
- 2026-11-03: The links of a review item become lines. A link of the kind
  "work that waits for the answer" or "options that conflict" becomes
  **Depends on**, on the item that must wait. A link of the kind "the same
  cause", "the same code", or "a shared wider fix" becomes **Do with** when
  one branch can fix both items.
- 2026-11-03, Milestone 1: A link that holds only for one option of an open
  decision stays in **Related**. The branch that applies the answer writes
  the line, because a false link misleads more than no link.
- 2026-11-03: `README.md` does not describe the listing, so it needs no
  change. The plans `SKILL.md` has 225 lines, so it gets words, not lines.

The script and the tests:

- 2026-11-03: `follow-ups.sh` stays one file. The `awk` pass for each item
  also prints the names of its two lines. One more `awk` pass after the sort
  finds the open items, the reverse links, and the groups.
- 2026-11-03: The script keeps to POSIX `awk` and bash 3.2, which macOS has.
- 2026-11-03: Three new tests in `tests/follow_ups_test.sh`. The existing
  tests of the exact output prove that an item without links lists as
  before.
  - `test_lists_the_links_of_an_item_under_it`: `depends on`, `needed by`,
    a path, a Markdown link, a wrapped line, and the score order. It fails
    when the script misses a link, misreads a name, or moves an item.
  - `test_lists_the_whole_do_with_group_on_each_member`: a one-sided link and
    a chain of three items. It fails when a link or a chain splits.
  - `test_marks_a_link_to_no_such_item`: a missing name and a link of an item
    to itself. It fails when the script exits with an error, shows the
    missing item as a wait, or lists an item with itself.

## Milestone 1: Rules and layout

Depends on: none

The `docs implementor` adds the two lines to the template, and states their
rules and the listing in the reference. The script follows in Milestone 2.

- [x] `skills/plans/templates/follow-up.md`: add the optional
      `**Depends on:**` and `**Do with:**` lines after **Reason**. Each
      placeholder says what the line names, and that the line is left out
      when it names no item.
- [x] `skills/plans/references/follow-up-items.md`, "Writing an item": when to
      write each line, the form of a name, a wrapped line, both sides of a
      link, the reason in **Related**, and the link kinds of a review.
- [x] Same file, "Work with more than one open question": the parent item
      names each open decision item on its **Depends on** line.
- [x] Same file, "Working on an item": the rules for the next item, for an
      item that waits for the user, for a named item, for two items that
      depend on each other, and for the branch that deletes an item.
- [x] Same file, "Listing the items": the four link lines and an example.
      "The priority score": the links do not change the score or the order.
- [x] `skills/plans/SKILL.md`, "Follow-up items": the sentence about the
      listing says "with the links of each item".
- [x] Walk the recorded cases of four repositories in
      `.context/follow-up-links/brainstorm.md` with the new text, as the
      `writing-skills` skill says. Save the walk in the same folder.
- [x] Run `scripts/check.sh` and the trailing-whitespace check.

Walk: `.context/follow-up-links/m1-walk.md`.

## Milestone 2: The listing

Depends on: 1

The `non-ui implementor` makes `follow-ups.sh` print the links.

- [x] Add the three tests of the design to `tests/follow_ups_test.sh`. Run
      them against the current script, and see each fail on an assertion.
- [x] Change `skills/plans/scripts/follow-ups.sh` and its header comment, as
      the design says.
- [x] Run `bash tests/follow_ups_test.sh` with gawk, with `gawk --posix`, and
      with mawk or the BWK `awk` when one is available. Name each `awk` that
      could not run. Save the output under `.context/follow-up-links/`.
- [x] Smoke test: run the script over `.context/follow-up-links/repos/`, and
      compare the output with the saved listings in the same folder. Then
      add the links of the gzip example to copies of its four items, and
      check the lines. Save the output in the same folder.
- [x] Run `scripts/check.sh` and `shellcheck` on the changed scripts.

Evidence: `.context/follow-up-links/m2-*`. I fixed a name that ends a sentence.

## Milestone 3: Verification, commit, review, and pull request

Depends on: 1, 2

The orchestrator runs the gate, the review, and the pull request.

- [x] Run the targeted tests and the complete gate named in `AGENTS.md`.
- [ ] Commit with Conventional Commits and push the branch. Watch CI as the
      `finish-work` skill says.
- [ ] Review the complete local diff against `origin/main` with the
      `implementation-review` skill after the push. Report the findings,
      then apply the fix rule: fix the `fix now` findings, record
      follow-up items under `plans/follow-ups/` for the rest, re-review
      once, and report.
- [ ] Delete this plan when the `plans` skill says, under "Deleting the
      plan".
- [ ] Open the pull request. Its description gives the decisions and the
      design calls of this plan with their dates, a permalink to this plan,
      and the follow-up items that the change adds. It says that an existing
      install gets the change when `update.sh` or `install.sh` runs there.
      Then watch CI as the `finish-work` skill says.
