# <The problem, in eight words or fewer>

- **Severity:** <High, Medium, or Low>. **Likelihood:** <Common or Rare, for a product bug only.> **Effort:** <Small, Medium, or Large.> **Confidence:** <High, Medium, or Low.> **Harder later:** <Yes or No.>
- **Kind:** <Fix after merge, Needs decision, Outside the scope, or Post-merge task.>
- **Added:** <YYYY-MM-DD>, from <the branch or the pull request, and the item number when there is one.>
- **Location:** <Each file path and line, or "None" when the work has no place in the code. Do not point to the body.>
- **Reason:** <One sentence: the fact about this work that makes it wait until after the merge. Do not only repeat the kind.>

<The body holds every fact that the work needs. A reader with only the
repository and this file can understand it, decide, and do the work. Do
not depend on a plan, a review report, a findings file, `.context/`, a
pull request, or a link. Read "Writing an item" in
`references/follow-up-items.md` of the `plans` skill. Keep the slots of
the item's kind and delete the slots of the other kind.>

<Every kind except a post-merge task. The slots are the item layout of the
`decisions-and-findings` skill. Fill each slot. The item holds one root
question. Work with more than one open question gets a parent item and
decision items, as `references/follow-up-items.md` says. A wider fix also
gives the problem of each finding that it covers. A blocked wider fix has
the kind Needs decision. A wider fix that the agent split off has the kind
Fix after merge.>

- **Terms:** <Each project term that the item uses, with one sentence that explains it. Or delete the slot when the item uses no such term.>
- **Background:** <Two to five sentences: what the feature does and where it is.>
- **Problem:** <One to three sentences that say what is wrong, with the evidence: a count, a failure text, or a line that you checked at the code.>
- **Screenshot:** <Only when the problem shows on a screen. One sentence: what the picture showed and what the box marked. When the source item has no picture, the screen and the state that show the problem, and the blocker. Or delete the slot.>
- **Impact if no action:** <One or two sentences.>
- **Root question:** <One question in the words of the goal. The options answer it.>
- **Options:**
  - **A.** <The change, its cost or risk. Effort: Small, Medium, or Large.>
- **Left out:** <Each approach that the options leave out, with its reason. When the item has fewer than three distinct approaches, one sentence that says why. Or "None".>
- **Wider fix:** <The letter of the option that prevents this class of issue. Or "None" and the reason, for example that a named skill rule or check already holds it.>
- **Previous examples:** <Earlier cases of this class, with commits or files, or "None found".>
- **Related:** <Each other follow-up item with a link to this one: its path, the kind of link, and what it means. Or delete the slot when the item has no link.>
- **Recommendation:** <Letter>. <One sentence of reasoning.>
- **Action:** <`fix after merge, apply` and a letter, with one sentence of reason. Or `ask the user, because` and one sentence that says which condition of the decision test holds.>

<A post-merge task.>

- **Terms:** <Each project term that the task uses. Or delete the slot.>
- **Background:** <What the task is about and where it is.>
- **Task:** <What to do.>
- **Impact if no action:** <One or two sentences.>
- **Needs:** <What the task needs, such as the deployed change or credentials, or "Nothing".>
- **Done when:** <The result that shows that the task is complete. When a status line links the item, also name the page of each status line that the item ends.>

<When a status line links an item of the first kind, end the item with a
**Done when** slot after **Action**, which names the page of each status
line that the item ends.>
