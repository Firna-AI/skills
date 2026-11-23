# Fix an unrelated failure

This file gives the procedure for a CI failure that "Find the cause" in
[ci.md](ci.md#find-the-cause) labels as unrelated. An unrelated failure
gets one fix in its own pull request from `main`: the fix pull request.
One fix there reaches every open branch.

1. Apply the decision test of the `decisions-and-findings` skill to the
   fix. The fix waits for the user when it needs a credential, a secret, a
   runner, a skipped test, or a gate change. It also waits when the cause
   stays unknown. When the fix waits, report the failure text, the rerun
   outcome, and the suspected source. Record them in a follow-up item, as
   the `plans` skill says.

   A change of a checksum, a dependency version, or a download URL does
   not make the fix wait. It makes the merge wait, as the merge step below
   says.

2. Search for an owner. An owner is an open pull request or a workspace
   that fixes the failure. Search the open pull requests, the remote
   branches under `ci-fix/`, the Conductor workspaces named `ci-fix:`, and
   the follow-up items on `origin/main`:

   ```sh
   gh pr list --state open --search "<failed step>"
   git ls-remote --heads origin 'ci-fix/*'
   conductor workspace list --name "ci-fix:" --repo <repository>
   git fetch origin main
   git grep -il "<failed step>" origin/main -- plans/follow-ups
   ```

   When an owner exists, name it in the report. Then wait, as the last step
   says. When a follow-up item records the failure, give the item to the
   fix pull request. That pull request deletes the item. When the item
   waits for the user, the failure waits too. Name the item in the report.

3. Claim the failure. First check the base branch again, as step 1 of
   "Find the cause" in [ci.md](ci.md#find-the-cause) says. Then push an
   empty commit on `origin/main` to a new branch `ci-fix/<job>-<step>`.
   Open a draft pull request from it, titled `fix(ci): <failure>`, with
   the failure text:

   ```sh
   claim=$(git commit-tree 'origin/main^{tree}' -p origin/main \
     -m "chore(ci): claim <failure> for <your branch>")
   git push origin "$claim:refs/heads/ci-fix/<job>-<step>"
   gh pr create --draft --base main --head ci-fix/<job>-<step> \
     --title "fix(ci): <failure>" --body-file <file>
   ```

   Write the job and the step in lowercase kebab-case, as in
   `ci-fix/rust-tests-build-hmrc-lts`. Your branch name in the commit
   message makes each claim commit unique. A push to an existing branch
   fails, so two agents cannot both claim. A rejected push means that
   another agent holds the claim. Then search again. When that claim is for
   another failure, add the test name to the branch name.

4. Start the fix in its own workspace, as the `delegating` skill says. The
   workspace starts from the claim branch, is named `ci-fix: <job>`, and
   runs the `default orchestrator` action:

   ```sh
   conductor workspace create --branch ci-fix/<job>-<step> \
     --name "ci-fix: <job>" --agent <agent> --model <model> \
     --effort <effort> --message-file <prompt>
   ```

   The prompt gives the failure text, the run URL, the rerun outcome, the
   suspected source, the claim branch, and the draft pull request. It names
   the follow-up item that records the failure, when one exists. It tells
   the agent to push each commit to the claim branch, with
   `git push origin HEAD:ci-fix/<job>-<step>`. It tells the agent to follow
   the `finish-work` skill, and then the merge step below. Outside
   Conductor, a worktree agent does the fix.

5. Merge. The agent of the fix pull request merges it into `main` only
   when all of these hold:

   - The `## CI` section of `AGENTS.md` on `origin/main` has the line
     `Agent merges: on, <method>`. The method is `merge`, `squash`, or
     `rebase`, as `gh pr merge` names it. Only the user turns the setting
     on. The setting on the fix branch does not count, so a fix pull
     request cannot turn it on.
   - The fix rule lets the agent make the fix without the user.
   - No finding of its review waits for the user.
   - Its diff changes no checksum or digest, dependency version or
     lockfile, download URL, secret, or CI workflow file.
   - Each CI run of its last commit passed, in a watch that started after
     the pull request became ready.

   Check the conditions other than CI first:

   ```sh
   git fetch origin main
   git show origin/main:AGENTS.md
   ```

   When they hold, mark the pull request ready. Then watch the CI of its
   last commit, because readiness can start more runs. Merge only when
   each run of that watch passed. The merge command also deletes the
   branch. Then watch the merge commit, because a push to `main` can
   deploy. Report a failure there to the user at once.

   ```sh
   gh pr ready <number>
   scripts/ci-wait.sh
   gh pr merge <number> --<method> --delete-branch
   git fetch origin main
   merge=$(gh pr view <number> --json mergeCommit --jq .mergeCommit.oid)
   scripts/ci-wait.sh "$merge"
   ```

   When a condition fails, mark the pull request ready. Report it to the
   user. Then stop.

6. Wait for the merge. As the agent of the branch, wait at most 60 minutes
   for the fix pull request to merge. Check its state every 5 minutes, with
   `gh pr view <number> --json state`.

   When it merges, merge the base branch of your pull request into the
   branch, with the `git-merge` skill. Push, and watch again. When the base
   branch is a primary branch of the `delegating` skill, it gets the fix
   only when its orchestrator merges `main`. Until then, report the red CI
   under **Open**, with the fix pull request. Report it there too when the
   time ends first.

Add no follow-up item for a failure that a fix pull request owns. The fix
pull request is the record. An item in your branch would stay after the
fix.

Example: in accounting pull request #740, the script named
`Rust tests: Build HMRC LTS`. The log said `LTS8.3.zip: FAILED`, because
HMRC had replaced the file at the same URL. The build failed again on the
next run of the branch and on `origin/main`, so the failure was unrelated.
The fix pull request, #741, pinned the new SHA-256. Its diff changes a
checksum, so the user merged it. Then #740 merged `main`, and its CI
passed.
