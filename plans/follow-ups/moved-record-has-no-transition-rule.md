# Moving a record leaves old records without a rule

- **Severity:** Medium. **Effort:** Small. **Confidence:** High. **Harder later:** No.
- **Kind:** Fix after merge.
- **Added:** 2026-11-06, from the branch `calummoore/ciproxy-mvp-plan-decisions`, review round 1, finding 1.
- **Location:** `skills/writing-skills/SKILL.md:142`, the checklist.
- **Reason:** The fix changes `skills/writing-skills/SKILL.md`, which the branch that found the problem does not change, so the fix rule sends it after the merge.

- **Terms:**
  - **Decisions file:** the file `plans/<plan-name>.decisions.md` beside a plan. It holds each decision of the change in full, with its answer. The `plans` skill defines it.
  - **Older plan:** a plan that already held decision text when the decisions file came in. The `plans` skill says that it keeps that text until the user approves a move.
- **Background:**
  - On 2026-11-06, the user chose to move each decision of a change out of the plan into a decisions file.
  - The first version of that change named only the decisions file in the rules that read a decision: the doc-drift rule of the review, the pull request record, and the plan deletion steps.
  - It said nothing about the plans that already held decisions, for example two active plans in `Firna-AI/ciproxy`. The review found the gap.
  - The fix added a rule for an older plan to the `plans` skill, and wrote the reader rules without a place, as "a recorded user decision".
  - The checklist of `skills/writing-skills/SKILL.md` has the line "When the text adds a kind of record, every list that says what an artifact holds names it." No line asks what happens to the records at the old place.
- **Problem:** When skill text moves a kind of record to a new place, no rule asks the writer to say what happens to the records that are already at the old place. No rule asks that the readers of the record find it at both places.
- **Impact if no action:** The next move of a record can again leave the old records unread. An agent can then ask the user again for a change that the user approved, or leave old decisions out of a pull request record.
- **Root question:** How does a skill writer keep the records at the old place usable when a change moves a kind of record?
- **Options:**
  - **A.** Add one line to the checklist of `skills/writing-skills/SKILL.md`: "When the text moves a kind of record to a new place, the rule at the new home says what happens to the records at the old place, and each rule that reads the record points to that home." The line adds no gate, and `writing-skills` loads only for work on skills. Effort: Small.
- **Left out:**
  - Change nothing: the review found this case, but nothing makes the next writer think of it.
  - A check in `scripts/check.sh`: a moved record is a meaning of the prose, not a path, so a script cannot see it.
  - Only one approach is left, because both other approaches fail the goal.
- **Wider fix:** A. It covers every record whose home moves.
- **Previous examples:** Commit `c76e1b7`, pull request #36 of 2026-10-28, added the checklist line about lists that name a new kind of record. The decisions file of 2026-11-06 is the first recorded case of a moved record.
- **Recommendation:** A. One checklist line costs little, and it reaches each later move of a record.
- **Action:** fix after merge, apply A, because the fix changes a file outside the diff of the branch that found the problem.
