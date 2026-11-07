# Link titles add false names to link lines

- **Severity:** Medium. **Likelihood:** Rare. **Effort:** Small. **Confidence:** High. **Harder later:** No.
- **Kind:** Fix after merge.
- **Added:** 2026-11-03, from the branch `calummoore/follow-up-dependencies`, review round 2, finding 3.
- **Location:** `skills/plans/scripts/follow-ups.sh`, the function `names()` at lines 46 to 61 and the function `link_fields()` at lines 64 to 72. `tests/follow_ups_test.sh`, the case table of `test_lists_the_links_of_an_item_under_it` at line 83.
- **Reason:** The bug needs a link title that no real item has yet, and the fix does not cost more later.
- **Do with:** `plans/follow-ups/first-list-end-misses-body-blocks.md`.

- **Terms:**
  - **Link line:** the optional `**Depends on:**` or `**Do with:**` line in the first list of a follow-up item. It names other items.
  - **Link title:** the optional text in quotes or parentheses after the target of a Markdown link, as `"title"` in `[text](target "title")`.
- **Background:**
  - `follow-ups.sh` of the `plans` skill lists the open follow-up items. Under each item it prints the items that its link lines name.
  - "Writing an item" in `skills/plans/references/follow-up-items.md` says: "A Markdown link counts by its target only."
  - `names()` finds a Markdown link with one pattern, which knows only a title in double quotes. For a link that the pattern misses, the script counts each word that ends in `.md`.
  - `link_fields()` splits a line at each bold label, such as `**Note:**`, before `names()` reads the text. It also splits a link whose title holds such a label.
  - CommonMark 0.31.2 allows a link title in double quotes, in single quotes, or in parentheses.
- **Problem:** On a **Depends on** line, `[beta.md](./alpha.md 'gamma.md')` lists `alpha.md, beta.md, gamma.md`, but only `alpha.md` is the target. A title in parentheses does the same. A title that holds `**Note:**` lists `alpha.md, beta.md`. A title that holds `**Do with:**` adds a false `do with:` group.
- **Impact if no action:** The listing can show false prerequisites, reverse links, and groups. A reader must open the item files to find the true links. A writer can avoid the bug with a bare path, which the template asks for.
- **Root question:** How does each link line list exactly the items that its writer names, for each form that a writer can put there?
- **Options:**
  - **A.** Extend the link pattern of `names()` with the two other title forms, and keep a link whole in `link_fields()`. Add the reproduced forms to the case table. Each new form needs one more pattern. Effort: Small.
  - **B.** Accept bare names and paths only, and drop the support for Markdown links in the script and the reference. A link that a writer copies from a **Related** line then adds the names of its text again. Effort: Small.
  - **C.** One reader for the first list and its inline links. It finds the fields, then resolves names only from the fields and the link targets. It stays in bash and POSIX `awk`. Effort: Medium.
  - **D.** One helper that reads each inline link by its parts. It drops the text in brackets, keeps the first word in the parentheses as the target, and skips to the closing parenthesis of the link. Call it in `link_fields()` before the label split, and in `names()`. A link that wraps waits for its next line. A link that never closes needs a flush at the end of the file. Add the reproduced forms, a title with `**Do with:**`, and a wrapped title with a label to the case table. The script grows from 177 to about 220 lines. Effort: Small.
  - **E.** Do D, and print an `unclear link:` line under an item for each link that the helper cannot close and for each reference-style link, as `[text][ref]`. The reference and the tests then describe five link lines. It adds a warning, so it needs the user. Effort: Medium.
- **Left out:**
  - Change nothing, and tests alone. Both leave the false links.
  - An external Markdown parser, such as `cmark` or a Python library. The script keeps to bash and POSIX `awk`, because macOS has them and the script runs on each machine that installs the skills.
  - A writing rule alone, as "a link has no title". A link with a title still gives false items, with no sign.
- **Wider fix:** D. Every reader of link text uses the one helper, so the text and the title of a link never reach a field or a name, whatever their form. A must know each title form, so A is a direct fix.
- **Previous examples:** Commit `06a6be5` fixed the case of a title in double quotes, as review finding 2 of round 1. The same review found this case of the class again in round 2.
- **Related:**
  - `plans/follow-ups/first-list-end-misses-body-blocks.md`, the same code. Both bugs live in the reader of the link lines in `score_item` of `follow-ups.sh`. The causes differ: this item is about the reading of a link, and that item is about the end of the first list. One branch can fix both.
- **Recommendation:** D. It removes the whole class at Small effort, in the files of the change, and no reader has to know each title form.
- **Action:** fix after merge, apply D, because the bug is Rare and Medium, and the fix does not get harder after the merge.

A scratch trial of D passed the 13 tests of `tests/follow_ups_test.sh` with gawk and `gawk --posix`. It listed only `alpha.md` for each of the 9 forms that the branch lists wrong, and it gave the same listing for the 341 items of `mokly-ai/mokly` and `mokly-ai/mokly-cloud`. No item in those repositories has a link title or a link line yet.
