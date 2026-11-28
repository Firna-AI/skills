# A deleted follow-up item leaves Related links

- **Severity:** Low. **Effort:** Small. **Confidence:** High. **Harder later:** No.
- **Kind:** Outside the scope.
- **Added:** 2026-11-28, from the branch `calummoore/spike-tests-for-unsure-ai-v6g1`, review round 2, a problem that the check of finding 8 found.
- **Location:** The rules that delete an item: `skills/plans/references/follow-up-items.md` lines 175 to 196, "Working on an item". `skills/implementation-review/SKILL.md` lines 190 to 192. `skills/finish-work/references/ci.md` line 170.
- **Reason:** The rules that delete an item were on `main` before the source branch, and the source branch only added the spike rule.

- **Terms:**
  - **Follow-up item:** a file under `plans/follow-ups/` that records work or a decision that waits until after the merge.
  - **Related line:** the slot of a follow-up item that names other items, the kind of each link, and what it means.
- **Background:**
  - Two linked items that stay apart each get a **Related** line that names the other file, as "Writing an item" says. One **Related** line can name more than one item, as the decision items of a parent item do.
  - An item file is deleted in these cases: a branch fixes the item, a fix pull request for a CI failure ends it, the user answers a decision item, the user drops an item, or a branch applies the user's answer to a review finding.
  - The closing rule in "Working on an item" says to remove or narrow each status line that links the item, and to search `docs/` and every `README.md` for links to it. No rule names the **Related** lines of other follow-up items.
  - The source branch added `plans/follow-ups/read-only-agents-cannot-run-spikes.md`, and added a **Related** line that links it to `plans/follow-ups/model-table-follows-only-conductor.md`, which came from #100.
- **Problem:** When one linked item is deleted, the other item keeps a **Related** line that names a deleted file.
- **Impact if no action:** A later reader of the other item follows a link to a file that no longer exists. The link also claims an overlap that is gone.
- **Root question:** How does the deletion of an item keep the links of other items correct?
- **Options:**
  - **A.** Add one rule to "Working on an item": the commit that deletes an item also removes each link to it from the **Related** lines of the other items under `plans/follow-ups/`. Remove the whole line only when it names no other item. The other deletion rules point to it. Effort: Small.
  - **B.** Do A, and make `skills/plans/scripts/follow-ups.sh` mark an item whose **Related** line names a missing file. It is a new check, so it needs the user. Effort: Medium.
- **Left out:** No **Related** lines between items. It breaks the rule in "Writing an item" that two linked items that stay apart each name the other. Only two approaches remain, because the fix either is a rule for the deleting commit or adds a check on top of it.
- **Wider fix:** A. The closing rule already lists each link that the deleting commit fixes, and A adds the missing kind.
- **Previous examples:** None found.
- **Related:**
  - `plans/follow-ups/fixed-follow-up-items-get-no-second-check.md`, the same cause: wrong **Related** links. Both items change `follow-up-items.md`, in other sections.
  - `plans/follow-ups/read-only-agents-cannot-run-spikes.md`, a shared file only: `follow-up-items.md`, in other sections.
- **Recommendation:** A. It is one sentence in the rule that the deleting branch already reads.
- **Action:** fix after merge, apply A, because the rules that delete an item were on `main` before the source branch.
