# Commit record list mixes description-only records

- **Severity:** Low. **Effort:** Small. **Confidence:** High. **Harder later:** No.
- **Kind:** Fix after merge.
- **Added:** 2026-11-28, from the branch `calummoore/spike-tests-for-unsure-ai-v6g1`, review round 2, the wider fix of finding 6.
- **Location:** `skills/git-commit/SKILL.md` lines 129 to 145, the list under "Record in the commit or PR description". `skills/finish-work/SKILL.md` line 122. `skills/git-merge/SKILL.md` lines 67 to 70. `skills/plans/references/deleting-a-plan.md` lines 4 to 6. `skills/plans/references/follow-up-items.md` lines 24 and 25. `skills/decisions-and-findings/references/outcomes.md` lines 229 to 231.
- **Reason:** The fix rewrites list entries that were on `main` before the source branch, and the source branch only added the spike rule.

- **Terms:**
  - **One-time proof:** a check that runs once for a task and never becomes a test, such as a migration check or a spike. The `testing` skill lists them.
  - **Record list:** the list in `skills/git-commit/SKILL.md` of what a commit message or a pull request description must record.
- **Background:**
  - The header of the record list, line 129, says "Record in the commit or PR description:". So each entry can sit in a commit body alone.
  - Three other skills require some of these entries in the pull request description:
    - `finish-work` line 122: the description lists each follow-up item that the change adds.
    - `git-merge` lines 67 to 70: "Justify each intentional decision in the PR description and name every path it affects. If no PR exists yet, save the justifications under `.context/<plan-name>/`, name that file in the active plan milestone, and copy them into the PR description when it opens."
    - `deleting-a-plan.md`: "The pull request description keeps the dated record". `follow-up-items.md` line 25 also says of a follow-up item: "The pull request description lists it."
  - `outcomes.md` line 230 says the description lists each `fix after merge` outcome. The record list has no entry for it.
  - Before 2026-11-28, the `testing` skill said to name the output file of a one-time proof "in the pull request". The source branch moved that rule into the record list. It had to add "When the work has a pull request, its description holds this record." to that one entry, because the header allows a commit alone. No other entry has such a sentence.
- **Problem:** The record list does not say which records belong in the description. The entries for follow-up items (line 144), merge decisions (line 138), and the record of a deleted plan (lines 141 to 143) fall under the header "commit or PR description", but three other skills require them in the description.
- **Impact if no action:** An agent that reads only `git-commit` can put these records in a commit body alone. A reader of the pull request then does not see them.
- **Root question:** How does an agent know which records the pull request description must hold?
- **Options:**
  - **A.** Add a sentence to each entry that the description must hold, as the one-time proof entry has: the follow-up items that the change adds, the merge decisions, and the record of a deleted plan. Add an entry for each `fix after merge` outcome with its reason, with the same sentence. The list gets longer, and each new entry needs the writer to remember the sentence. Effort: Small.
  - **B.** Split the record list in two. A new list says what the description holds: each one-time proof with its result and output file, each follow-up item that the change adds, each intentional merge decision with its paths, the dated record of a deleted plan, and a new entry for each `fix after merge` outcome with its reason. Keep where each source puts a record before the pull request opens: the commit for most records, and a file under `.context/<plan-name>/` for merge decisions, as `git-merge` says. The other entries stay under "Record in the commit or PR description". The deletion of a follow-up item stays there too, because no source requires it in the description. Effort: Small.
- **Left out:** Change nothing. It fails the goal, because only the one-time proof entry says that the description holds it. Make the description hold every record of the list. It changes the rule for removals, removed tests, plan edits, design calls, and fixed finding numbers, and no decision covers that change. A check of the description in CI. A new gate needs the user, and CI cannot read the git-ignored `.context/` folder.
- **Wider fix:** B. One list for the description makes the place of each new record clear.
- **Previous examples:** The source branch, commit `9ae7880`, moved the one-time proof rule into the list and lost its pull request condition. Review round 2 found it.
- **Recommendation:** B. It makes `git-commit` agree with the three skills that already require these records in the description.
- **Action:** fix after merge, apply B, because it rewrites list entries on `main` that the spike change does not touch.
