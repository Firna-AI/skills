# Fix an unrelated failure

This file gives the procedure for a CI failure that "Find the cause" in
[ci.md](ci.md#find-the-cause) labels as unrelated. An unrelated failure
gets one fix in its own pull request from `main`: the fix pull request.
One fix there reaches every open branch.

Conductor and Conductive are apps that run each workspace on its own
machine. Step 3 claims the failure with a claim branch and a draft pull
request from it: the claim pull request. Some steps differ by app:

- In Conductor, the claim pull request becomes the fix pull request. The
  fix workspace pushes to the claim branch.
- In Conductive, a new workspace always works on a new branch of its own:
  the workspace branch. The app follows only that branch for its pull
  request bar, its checks, and its GitHub events. So the fix pull request
  comes from the workspace branch. The claim pull request closes with a
  link to it.

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
   branches under `ci-fix/`, the workspaces named `ci-fix:` in your app,
   and the follow-up items on `origin/main`:

   ```sh
   gh pr list --state open --search "<failed step>"
   git ls-remote --heads origin 'ci-fix/*'
   conductor workspace list --name "ci-fix:" --repo <repository>  # Conductor
   conductive workspaces list --repository <repository-id> \
     --query "ci-fix:" --archived false                           # Conductive
   git fetch origin main
   git grep -il "<failed step>" origin/main -- plans/follow-ups
   ```

   In Conductive, `conductive repositories list` gives the repository id.
   Each workspace in the list gives its branch. A fix pull request in
   Conductive comes from such a branch, not from `ci-fix/`.
   `gh pr list --state all --head <branch>` gives the pull requests of a
   branch. The timeline of a claim pull request lists its fix pull
   request, as the wait step below shows.

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

   In Conductive, a person can delete a claim branch after its claim pull
   request closes. So check for an earlier claim between the push and
   `gh pr create`. An earlier claim pull request of the branch still holds
   the claim when its fix pull request is open. The wait step below shows
   how to find that fix pull request.

   When an earlier claim still holds, put the head commit of its claim
   pull request back, with a lease on your claim commit. Its fix agent can
   then still end that claim. Then wait for that fix pull request, as the
   last step says:

   ```sh
   gh pr list --state all --head ci-fix/<job>-<step> --json number,state
   git fetch origin "refs/pull/<earlier claim>/head"
   git push origin FETCH_HEAD:refs/heads/ci-fix/<job>-<step> \
     --force-with-lease=refs/heads/ci-fix/<job>-<step>:<your claim commit>
   ```

4. Start the fix in its own workspace, as the `delegating` skill says. The
   workspace is named `ci-fix: <job>` and runs the `default orchestrator`
   action. In Conductor, it starts from the claim branch. In Conductive,
   it starts from `main` and targets `main`. The claim branch holds only
   the empty claim commit, so the fix needs nothing from it. The
   `create_workspace` tool of Conductive takes the same values as its
   command:

   ```sh
   conductor workspace create --branch ci-fix/<job>-<step> \
     --name "ci-fix: <job>" --agent <agent> --model <model> \
     --effort <effort> --message-file <prompt>
   conductive workspaces create --repository <repository-id> \
     --name "ci-fix: <job>" --start-branch main --base-branch main \
     --agent <agent> --model <model> --effort <effort> \
     --message-file <prompt>
   ```

   The prompt gives the failure text, the run URL, the rerun outcome, the
   suspected source, the claim branch, and the claim pull request. It
   names the follow-up item that records the failure, when one exists. It
   tells the agent where to push each commit:

   - In Conductor, the agent pushes to the claim branch, with
     `git push origin HEAD:ci-fix/<job>-<step>`.
   - In Conductive, the agent pushes to its workspace branch. It never
     pushes to the claim branch. The prompt also gives the claim commit,
     for the merge step.

   The prompt tells the agent to follow the `finish-work` skill and this
   file, `references/ci-fix.md` of that skill. At the pull request step of
   `finish-work`, the agent follows the next step below. After
   `finish-work`, it follows the merge step below. Outside Conductor and
   Conductive, a worktree agent does the fix and pushes to the claim
   branch.

5. Open the fix pull request. In Conductor, the claim pull request is the
   fix pull request, so this step adds nothing. In Conductive, the agent
   of the fix workspace opens the fix pull request at the pull request
   step of `finish-work`, in this order:

   - It reads the state of the claim pull request. When the claim pull
     request is closed and the workspace branch has no fix pull request
     yet, someone else ended the claim. Then the agent opens no fix pull
     request. It reports the claim, its comments, and its branch to the
     user, and stops.
   - It writes the title and the description with the `git-commit` skill.
     The first line of the description is `Claim: #<claim>`. The failed
     job and step, the failure text, and the run URL follow. So the
     search for an owner finds the fix pull request.
   - It opens the fix pull request as a draft, from its workspace branch
     into `main`. The merge step below marks it ready.
   - It links the fix pull request in a comment on the claim pull
     request: "The fix pull request is #<number>. Keep this branch until
     it merges. The branch holds the claim." Then it closes the claim pull
     request, when it is open.

   ```sh
   gh pr view <claim> --json state --jq .state
   gh pr create --draft --base main --title "<title>" --body-file <file>
   gh pr comment <claim> --body-file <comment>
   gh pr close <claim>
   ```

   When the agent does this step again, it uses the fix pull request that
   its branch already has. Keep the claim branch. It holds the claim until
   the fix pull request merges, so that no other agent claims the failure.

6. Merge. The agent of the fix pull request merges it into `main` only
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
   each run of that watch passed. Then watch the merge commit, because a
   push to `main` can deploy. Report a failure there to the user at once.

   ```sh
   gh pr ready <number>
   scripts/ci-wait.sh
   gh pr merge <number> --<method> --delete-branch   # Conductor
   gh pr merge <number> --<method>                   # Conductive
   git fetch origin main
   merge=$(gh pr view <number> --json mergeCommit --jq .mergeCommit.oid)
   scripts/ci-wait.sh "$merge"
   ```

   In Conductor, the merge command also deletes the claim branch, the head
   of the pull request. In Conductive, leave out `--delete-branch`. It
   would check out `main`, and Continue moves a workspace only from its
   own branch.

   In Conductive, then end the claim. First check that the fix pull
   request has the state `MERGED`. Then delete the claim branch only while
   it holds the claim commit, so that the push cannot delete a newer
   claim:

   ```sh
   gh pr view <number> --json state --jq .state
   git push --force-with-lease=refs/heads/<claim branch>:<claim commit> \
     origin --delete <claim branch>
   ```

   A rejected delete means that the claim branch is gone, or that it holds
   a newer claim. Then leave the branch.

   When a condition fails, mark the pull request ready. Report it to the
   user. Then stop.

7. Wait for the merge. As the agent of the branch, wait at most 60 minutes
   for the fix pull request to merge. Check its state every 5 minutes, with
   `gh pr view <number> --json state`.

   In Conductive, each check also reads the claim and the fix workspace:

   - The fix pull request is the pull request whose description starts
     with the line `Claim: #<claim>`. The timeline of the claim pull
     request lists it. Until it exists, use the claim pull request in its
     place.
   - When the claim pull request is closed and no fix pull request
     exists, the claim ended without a fix. Then stop the wait. Report
     the claim, its comments, and the red CI under **Open**.
   - When the first session of the fix workspace has the state `failed`,
     stop the wait. Report the failure and the claim to the user at once.
     The create reply, or the workspace list of step 2, gives the id of
     the workspace.

   ```sh
   gh api "repos/{owner}/{repo}/issues/<claim>/timeline" --paginate \
     --jq '.[] | select(.event == "cross-referenced") | .source.issue
       | select(.pull_request != null)
       | select((.body // "") | split("\n")[0] | rtrimstr("\r")
         == "Claim: #<claim>") | .number'
   conductive sessions list --workspace <workspace-id>
   ```

   When the fix pull request merges, merge the base branch of your pull
   request into the branch, with the `git-merge` skill. Push, and watch
   again. When the base branch is a primary branch of the `delegating`
   skill, it gets the fix only when its orchestrator merges `main`. Until
   then, report the red CI under **Open**, with the fix pull request.
   Report it there too when the time ends first.

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
