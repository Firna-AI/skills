# Decide the fate of the old coordinator PR

- **Severity:** Low. **Effort:** Small. **Confidence:** High. **Harder later:** No.
- **Kind:** Post-merge task.
- **Added:** 2026-11-02, from branch `calummoore/coordinator-skill-design`, the post-merge follow-up of its plan.
- **Location:** None.
- **Reason:** Closing PR #37 is an outward-facing action, so it waits for the user's word after the new `coordinator` skill merges.

- **Terms:**
  - **PR #37:** the open pull request `futex-ai/skills#37`, branch `calummoore/conductor-workspace-coordinator-skill`. It adds an older `conductor-section-workspace-coordinator` skill: one coordinator per Conductor sidebar section, with an hourly wake routine and goal reviews.
  - **Follow-up item:** one file under `plans/follow-ups/`, in the layout of `skills/plans/templates/follow-up.md`.
- **Background:**
  - On 2026-11-01 the user chose a new, small `coordinator` skill instead of PR #37. The new skill lives in `skills/coordinator/`. It takes the transcript reader and its tests from PR #37.
  - PR #37 holds follow-up items that are not on `main`. Five of them concern files that are on `main`, so they still apply when PR #37 closes. They live on its branch under `plans/follow-ups/`:
    - `delegating-session-wait-rule.md`: the `delegating` skill waits for a session to show `idle`, which misses failed turns and turns that go on. The new reader `skills/coordinator/scripts/last-report.sh` already handles both cases, so its option B now means: point the `delegating` skill to that reader.
    - `writing-skills-template-frontmatter.md`: the skill template `skills/writing-skills/templates/SKILL.md` holds invalid YAML in its description.
    - `writing-skills-template-listed-as-skill.md`: Codex lists that template as a skill.
    - `review-prompts-six-fields.md`: the review prompts lack the six prompt fields of the `delegating` skill.
    - `skill-frontmatter-yaml-check.md`: `scripts/check.sh` does not parse the frontmatter as YAML. It needs the user's decision, because each option adds a gate.
  - One open decision of the PR #37 conversation has no file: no action of the `models` skill uses the Codex model `gpt-6-astra`. The proposed option was a `complex implementor` action on Codex `gpt-6-astra` at max effort, for non-UI work that changes a shared contract, concurrency, or the architecture. The other option was to add no action. It needs the user's decision, because it changes the action table that the user set.
  - The other six follow-up items of PR #37 concern its wake routine, its section scan, and its orchestrator binding. The new skill has none of these, so they do not apply.
- **Task:**
  1. Ask the user whether to close PR #37.
  2. When the user agrees, copy the five files above from its branch to `plans/follow-ups/` on a new branch. Update `delegating-session-wait-rule.md` to name the new reader. Add one item of the kind Needs decision for the Codex `gpt-6-astra` action.
  3. Merge that branch. Then close PR #37 with a comment that names the new skill and the merged follow-up items.
- **Impact if no action:** PR #37 stays open. If it closes without step 2, five live follow-up items and one open decision are lost.
- **Needs:** the user's word on PR #37.
- **Done when:** PR #37 is closed or the user keeps it open, and each of the five items and the new decision item is on `main` when it is closed.
