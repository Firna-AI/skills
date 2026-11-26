# Mockups skill names only two product-ui rule groups

- **Severity:** Low. **Effort:** Small. **Confidence:** High. **Harder later:** No.
- **Kind:** Outside the scope.
- **Added:** 2026-11-26, from the branch `calummoore/product-ui-whole-row-links-rule-n7mr`, review round 2, outside-scope list.
- **Location:** `skills/mockups/SKILL.md`, lines 8 to 10.
- **Reason:** The fix changes the `mockups` skill, and the branch that found the problem had the instruction to change no skill other than `product-ui`.

- **Terms:**
  - **`product-ui` skill:** the shared skill at `skills/product-ui/SKILL.md`. It holds the rules for screens, components, mockups, and user-facing text.
  - **`mockups` skill:** the shared skill for design mockups under `docs/mockups` in a product repository.
- **Background:**
  - `skills/mockups/SKILL.md` lines 8 to 10 say: "The forbidden visual patterns and copy rules in the `product-ui` skill apply to mockups too."
  - `skills/product-ui/SKILL.md` has more sections than those two. The section "Rows and click targets" also applies to mockups, and it says so in its last bullet. The cause of that section was a mockup: in the mokly repository, `docs/mockups/src/components/content-list.tsx` made only a trailing "Open" link clickable.
  - The section "Real data only" of `product-ui` does not apply to mockups in full. It allows faked data in mockups.
- **Problem:** The `mockups` skill lists only two `product-ui` rule groups for mockups. An agent that reads only the `mockups` skill can conclude that the other groups, such as "Rows and click targets", do not apply to mockups.
- **Impact if no action:** An agent that builds a mockup can skip the row rule, and the implementation then copies the mockup.
- **Root question:** How does an agent that builds a mockup know which `product-ui` rules apply to it?
- **Options:**
  - **A.** Change nothing. Each `product-ui` section that applies to mockups says so itself, and the `product-ui` description already loads at a mockup. Effort: Small.
  - **B.** Add "and the row and click target rules" to the sentence in `mockups`. The list must then grow with each new `product-ui` section. Effort: Small.
  - **C.** Replace the sentence with: "The `product-ui` skill applies to mockups too. Each of its sections says when a rule differs for mockups." Effort: Small.
- **Left out:** A lint that compares the two skills. Doc prose gets no test or lint, and a new lint needs the user.
- **Wider fix:** C. One sentence covers every present and later `product-ui` section.
- **Previous examples:** None found.
- **Recommendation:** C. It removes the list that can go stale, and `product-ui` already states the one exception for mockups.
- **Action:** fix after merge, apply C.
