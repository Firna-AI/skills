# Record the cases of a real coordinator run

- **Severity:** Low. **Effort:** Medium. **Confidence:** High. **Harder later:** No.
- **Kind:** Post-merge task.
- **Added:** 2026-11-02, from branch `calummoore/coordinator-skill-design`, the post-merge follow-up of its plan.
- **Location:** `skills/coordinator/SKILL.md`, `skills/coordinator/references/cycle.md`, `skills/coordinator/templates/messages.md`, `skills/coordinator/templates/state.md`.
- **Reason:** These moments need a real run of the new skill, which can start only after the skill merges.

- **Terms:**
  - **Coordinator:** a session that runs the `coordinator` skill. It manages other Conductor workspaces, its children, sends the user every item of a child, and merges each pull request into `main`.
  - **Case:** a real moment from a recorded session, with what the agent did and its words, as the `writing-skills` skill says under "Check the skill against a repository".
- **Background:**
  - The skill text was written from 38 recorded cases of three earlier sessions, which coordinated workspaces before the skill existed. No record covered these moments:
    - a workspace that the user hands to the coordinator,
    - a child item sent to the user with the child's own number, and the answer passed back in that number,
    - a child plan that waits for approval, and a child that asks to split,
    - a child pull request with a merge conflict, a draft, or a merge method that `AGENTS.md` names,
    - a request to other children to merge `main` after a merge,
    - a compaction or a lost role in a coordinator session, and a handover to a new session through the board,
    - a cycle that ends with no wait, and a wake from outside the skill.
  - For these moments the text rests on the design, not on a case.
- **Task:** After the first real coordinator run that meets some of these moments, read its transcript. Record each such moment as a case, with its place, what the agent did, and its words. Walk each case with the skill text. Fix the text where a case does not get the instruction that changes its outcome.
- **Impact if no action:** a gap in the text for these moments shows only when a run fails on it.
- **Needs:** a real coordinator session and its transcript.
- **Done when:** each moment above that the run met has a recorded case, and the text gives each case its instruction.
