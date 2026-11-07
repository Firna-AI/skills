# Body blocks after the first list add links

- **Severity:** Medium. **Likelihood:** Rare. **Effort:** Small. **Confidence:** High. **Harder later:** No.
- **Kind:** Fix after merge.
- **Added:** 2026-11-03, from the branch `calummoore/follow-up-dependencies`, review round 2, finding 4.
- **Location:** `skills/plans/scripts/follow-ups.sh`, the reader of the first list at lines 76 to 83. `skills/plans/references/follow-up-items.md`, "Writing an item", line 72. `tests/follow_ups_test.sh`, the case table of `test_lists_items_by_score_with_the_count` at line 38.
- **Reason:** The bug needs an item with no blank line after its first list, and no real item has such a layout.
- **Do with:** `plans/follow-ups/link-title-adds-false-names.md`.

- **Terms:**
  - **Link line:** the optional `**Depends on:**` or `**Do with:**` line in the first list of a follow-up item. It names other items.
  - **First list:** the list of grades and fields directly after the title of an item. The template puts the link lines in it, after **Reason**.
- **Background:**
  - `follow-ups.sh` of the `plans` skill lists the open follow-up items. It reads the link lines only from the first list, so that a label in the body adds no link.
  - "Writing an item" in `skills/plans/references/follow-up-items.md` says: "The script reads no link line after that list, so a label in the body adds no link."
  - The reader starts the first list at the first line that starts with `- `. It ends the list only at a blank line. Every other line keeps the list open.
  - In Markdown, a heading, a fence, a rule, a quote, or another block also ends a list.
- **Problem:** After the title, this fragment lists `depends on: beta.md`, because the heading does not end the first list:

  ```markdown
  - **Reason:** It waits.
  ## Background
  - **Depends on:** beta.md
  ```

  A fence, a rule, a quote, an HTML line, or an unindented line does the same. The finding check also found a related case: the reader knows only `- ` items, so a first list with `*` or `+` bullets gives no link, and a later `- ` list in the body gives false links.
- **Impact if no action:** A body example can add false prerequisites and reverse links. A blank line after the first list avoids the bug, and the template has one.
- **Root question:** How does the listing take links only from the first lines of an item, and never from a later block?
- **Options:**
  - **A.** End the first list also at a heading and at the other block forms that the reader names. Add this case to the case table. Each new block form needs one more rule. Effort: Small.
  - **B.** Require a blank line after the first list, and report each file without one. Update the format rules. It adds a stricter validation, so it needs the user. Effort: Small.
  - **C.** Use the one reader of option C of `plans/follow-ups/link-title-adds-false-names.md`, which selects the first list before it reads any field. Effort: Medium.
  - **D.** End the first list at its first line that is not a top-level `- ` item and not an indented line. A blank line, a heading, a fence, a rule, a quote, an HTML line, another list, or an unindented line then ends the list. Change two lines of the reader. State the rule in the header comment and in "Writing an item". Add rows for a heading, a fence, and a rule to the case table. A link line after an unindented wrap in the first list then stops counting. The current code already drops the names of such a wrap, and no real item has one. Effort: Small.
- **Left out:**
  - Change nothing, and escaping the labels in the body. Both leave the false links.
  - A CommonMark parser. The script keeps to bash and POSIX `awk`, because macOS has them and the script runs on each machine that installs the skills.
  - A delimited metadata block, such as front matter. It breaks the layout that the user chose on 2026-11-03: two optional lines in the first lines of an item.
- **Wider fix:** D. It ends the list at each line shape that the first list does not use, so a new block form cannot open the gap again. A must know each form, so it is a direct fix.
- **Previous examples:** Commit `06a6be5` made the reader take link lines only from the first list, as review finding 1 of round 1. It ended the list only at a blank line.
- **Related:**
  - `plans/follow-ups/link-title-adds-false-names.md`, the same code. Both bugs live in the reader of the link lines in `score_item` of `follow-ups.sh`. The causes differ: this item is about the end of the first list, and that item is about the reading of a link. One branch can fix both.
- **Recommendation:** D. It closes every block form at the end of the first list with two changed lines, and it does not wait for the other item.
- **Action:** fix after merge, apply D, because the bug is Rare and Medium, and the fix does not get harder after the merge.

A scratch trial of D passed the 13 tests of `tests/follow_ups_test.sh` with gawk, `gawk --posix`, and `gawk --traditional`. It removed the false link in ten reproduced cases, and it listed the 344 real items of this repository and the two mokly repositories byte for byte as before. All 344 items end their first list with a blank line, and none uses `*` or `+` bullets there. The `*` and `+` case needs its own option: a reader that starts the first list directly after the title drops the links of an item with a paragraph before its first list.
