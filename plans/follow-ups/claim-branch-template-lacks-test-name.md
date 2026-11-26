# Claim branch template lacks the test name

- **Severity:** Medium. **Effort:** Small. **Confidence:** Medium. **Harder later:** No.
- **Kind:** Outside the scope.
- **Added:** 2026-11-23, from the branch `calummoore/ci-fix-steps-own-workspace-branch-in-bk7g`, review round 1, the check of finding 1.
- **Location:** `skills/finish-work/references/ci-fix.md`, step 4 "Start the fix", the `conductor workspace create` command and the Conductor push command `git push origin HEAD:ci-fix/<job>-<step>`.
- **Reason:** These commands are Conductor steps that the branch kept as they were, as the user asked on 2026-11-23.

- **Terms:**
  - **Claim branch:** the branch `ci-fix/<job>-<step>`, with one empty commit on `main`. It is the lock that stops two agents from claiming one CI failure.
  - **Conductor:** an app that runs each agent workspace on its own machine. In Conductor, the fix workspace pushes each commit to the claim branch.
- **Background:**
  - `skills/finish-work/references/ci-fix.md` gives the procedure for an unrelated CI failure. Step 3 claims the failure with a push to `ci-fix/<job>-<step>`.
  - Step 3 also says: "When that claim is for another failure, add the test name to the branch name." So a claim branch can be `ci-fix/<job>-<step>-<test>`.
  - In Conductor, step 4 starts the fix workspace with `conductor workspace create --branch ci-fix/<job>-<step>`. The prompt tells the agent to push with `git push origin HEAD:ci-fix/<job>-<step>`.
  - The Conductive merge step names the branch as `<claim branch>`, so it holds the test name when the claim has one.
  - A check found the problem by a reading of the text. Nobody met it in a real run.
- **Problem:** When the claim branch has the test name, the Conductor commands as written name the claim branch of the other failure. An agent that copies them starts from that claim and pushes its fix to it.
- **Impact if no action:** When two failures share one job and step, the second fix can land on the pull request of the first. Then a person must move the commits.
- **Root question:** How does each command after the claim name the claim branch that the agent pushed?
- **Options:**
  - **A.** Change nothing. The agent reads the rule of the test name and changes the commands by itself. Effort: Small.
  - **B.** Name the branch `<claim branch>` in the Conductor commands of step 4, as the Conductive merge step does. The flow of Conductor stays the same. Effort: Small.
  - **C.** Always add the test name, or another unique part, to each claim branch. This changes the name of every claim and the search for an owner in step 2. Effort: Small.
- **Left out:** A shell variable that the claim sets and each later command reads. An agent runs each command in a separate shell, so the variable does not stay. A script that claims the failure and prints the branch. It adds a script and its tests, and B gives the same result with one placeholder.
- **Wider fix:** B. One placeholder names the claim branch in each command, whatever the name holds.
- **Previous examples:** None found.
- **Recommendation:** B. It changes one placeholder in two commands and matches the Conductive merge step.
- **Action:** fix after merge, apply B, because the commands are Conductor steps that this branch kept as they were.
