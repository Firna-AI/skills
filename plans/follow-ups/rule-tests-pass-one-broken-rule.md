# Test of several rules passes one broken rule

- **Severity:** Low. **Effort:** Medium. **Confidence:** High. **Harder later:** No.
- **Kind:** Needs decision.
- **Added:** 2026-11-06, from the branch `calummoore/follow-up-list-pending-choices`, review round 1, finding 1, as its blocked wider fix.
- **Location:** `skills/testing/SKILL.md`, the section "Prove that each test can fail" at lines 68 to 80, and the checklist line "You saw each new test fail on an assertion." at line 194.
- **Reason:** The fix changes a rule of the shared `testing` skill that every repository loads, and no user decision covers it.

- **Terms:**
  - **Rule of a test:** one behaviour that a case of a test checks, such as "keep the last top-level line" or "ignore an indented line".
  - **Broken copy:** a copy of the code under test with one deliberate change that breaks one rule.
- **Background:**
  - "Prove that each test can fail" in the `testing` skill asks to see each new test fail on an assertion. When the test comes before the code, that run happens before the code exists.
  - Such a run shows only that the whole change is missing. It does not show that each rule of the test can fail alone.
  - `test_shows_the_action_outcome_beside_the_kind` in `tests/follow_ups_test.sh` failed once, before `follow-ups.sh` of the `plans` skill read the **Action** line. A review then made three broken copies of the script: keep the first top-level **Action** line, accept an indented line, and match the label anywhere in a line. Each copy passed every test, so the branch added two cases.
  - In `mokly-ai/mokly-cloud`, `plans/follow-ups/catalogue-sync-order-test-gap.md` records a test that checks the result of a Stripe catalogue sync but not the order of its requests.
- **Problem:** The `testing` skill accepts one failing run for a test that holds cases for several rules. A break of one rule can then pass every test.
- **Impact if no action:** A later change can break one rule of a tested behaviour while the gate passes. Only a review finds such a gap, and only by chance.
- **Root question:** How does a test with cases for several rules prove that each rule can fail alone?
- **Options:**
  - **A.** Change nothing. Reviews keep finding the gaps, as the review of the listing test did. Effort: Small.
  - **B.** Ask the reviewer to do it. The review prompt of the `implementation-review` skill asks the reviewer to break each rule of a new test in a copy of the code. The writer of the test keeps the current rule. Effort: Small.
  - **C.** Change "Prove that each test can fail" and its checklist line in the `testing` skill. When a test holds cases for more than one rule, break each rule alone in a copy of the code, and see the test fail each time. The skill has 199 lines, so the text must stay short. The `writing-skills` skill asks for recorded cases before the text changes. Effort: Medium.
  - **D.** Add a mutation-testing step to the gate of each repository. Each language needs its own tool, and the step adds a gate. Effort: Large.
- **Left out:** None.
- **Wider fix:** C. The writer of each test proves each rule, so the gap does not reach the review.
- **Previous examples:** The listing test and the Stripe catalogue sync test that the background describes.
- **Recommendation:** C. It moves the proof to the moment when the writer knows the rules. B is cheaper, but it finds the gap only after the code exists.
- **Action:** ask the user, because C changes a rule of the shared `testing` skill, and no user decision covers it.
