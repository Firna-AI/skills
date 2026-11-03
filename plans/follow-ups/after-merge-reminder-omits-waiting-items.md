# Reminder after the merge omits waiting items

- **Severity:** Low. **Effort:** Small. **Confidence:** High. **Harder later:** No.
- **Kind:** Outside the scope.
- **Added:** 2026-11-03, from the branch `calummoore/follow-up-list-pending-choices`, the options check of its plan.
- **Location:** `skills/finish-work/SKILL.md`, step 8 "Report" at line 131 and step 9 "After the merge" at lines 138 to 145. `skills/plans/scripts/follow-ups.sh`, the count line at line 177. `skills/plans/references/follow-up-items.md`, "Listing the items".
- **Reason:** The fix adds a number to every final report and reminder, and the branch that found it changes only the line of each listed item.

- **Terms:**
  - **Waiting item:** a follow-up item that waits for the user's answer. "Working on an item" in `skills/plans/references/follow-up-items.md` defines it from the **Kind** and the **Action** line.
  - **Reminder after the merge:** step 9 of the `finish-work` skill. When a pull request merges, the agent reminds the user of the open follow-up items.
- **Background:**
  - The reminder after the merge names the items that the change added, and gives the number of all open items.
  - The final report of step 8 also gives the number of open follow-up items.
  - `follow-ups.sh` of the `plans` skill ends with the line `open follow-up items: <number>`. Both reports take that number.
  - Each line of the listing shows the kind and the outcome of the **Action** line of the item, as `[Outside the scope | ask the user]`.
  - On 2026-11-03, 179 of the 378 items of six repositories waited for the user.
- **Problem:** The final report and the reminder after the merge give only the number of all open items. They do not say how many items wait for the user's answer, or which ones.
- **Impact if no action:** The user learns of a waiting item only from the full list or from the item itself. Decisions can stay open longer.
- **Root question:** How does the user learn, at the end of a task or after a merge, which follow-up items wait for an answer?
- **Options:**
  - **A.** Change nothing. The user reads the list for `ask the user`. Effort: Small.
  - **B.** `follow-ups.sh` prints `waiting for the user: <number>` directly before its last line. The final report and the reminder after the merge give that number beside the number of open items. Add a test, and update "Listing the items" and the `finish-work` skill. Effort: Small.
  - **C.** Do B. The reminder after the merge also names each waiting item by its path and title. A repository with many waiting items then gets a long reminder. In `mokly-ai/mokly-cloud`, 91 of 183 items wait. Effort: Small.
- **Left out:** A second script that lists only the waiting items. It repeats the reader of `follow-ups.sh`, and B gets the number from the same pass, so B is better on every point.
- **Wider fix:** B. The script gives the number, so each report gives it the same way.
- **Previous examples:** None found.
- **Recommendation:** B. It gives the number at the two moments when the user reads a report, at a Small cost.
- **Action:** ask the user, because B adds a number to what every final report and reminder says, and no requirement covers it.
