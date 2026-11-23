# CI

This file gives the procedure of the CI step in the `finish-work` skill.
It covers the GitHub Actions runs of each commit that you push. A run that
no session watches is outside it, such as a run on a bot branch or a
scheduled run.

## Watch

To watch a commit, run `scripts/ci-wait.sh [<commit>]` of the
`finish-work` skill in the background. The commit is `HEAD` by default.

The script waits for every run of the commit. It ends only when no run or
status changed for the grace period, 120 seconds by default, and in two
polls in a row. So a run still joins the watch when a pull request
opening, a change to ready, a rerun, or another run starts it late. It
prints one line for each run: the result, the workflow, and the URL. Under
a run that did not pass, it names each failed job and its first failed
step.

- Watch the last commit after each change that can start CI. These changes
  are a push, the opening of the pull request, and a change from draft to
  ready. A result from before the last change does not count. Only the
  runs of the last commit decide the merge.
- The script keeps no state. When a tool stops it, run it again on the
  same commit.
- Some repositories run CI on pull requests only. There, a push before the
  pull request opens starts no run.

Act on the exit status of the script:

- 0: every run passed. Go on.
- 1: a run ended without a pass, for example with `failure` or
  `cancelled`. Read the failure, as the next section says.
- 2: a run still ran at the deadline, 60 minutes by default. Report it
  under **Checks** as pending.
- 3: no run started in the grace period, 120 seconds by default. When a
  pull request is open, check it for a conflict with
  `gh pr view --json mergeable --jq .mergeable`. Check again while it says
  `UNKNOWN`. `CONFLICTING` means that CI cannot start. Then merge the base
  branch, as step 1 of "Find the cause" says, and watch again. Otherwise,
  the change starts no CI.
- 4: a usage error, no `gh`, or three failed `gh` calls in a row. Correct
  the call. Run the script again. When it fails again, report the blocker
  under **Checks**.

## Read a failure

First read the conclusion of the run:

- A `cancelled` run: watch the newer commit when one exists. Otherwise,
  rerun the run once with `gh run rerun <run>`.
- An `action_required` run waits for a person. Ask the user.
- Any other run: read the log of its failed jobs.

```sh
gh run view <run> --log-failed
```

The run id is the last number in the run URL. Start at the first failed
step that the script names. Find its first error there. Skip a summary
job, such as "Verify required jobs". It only repeats the other failures.

## Find the cause

1. This section gives each failure one label: a failure of the branch, a
   flaky test, or an unrelated failure. Before you label a failure as one
   of the branch or as unrelated, check the base branch. Check it before a
   claim too. A pass on a rerun makes a flaky test without this check. The
   command takes the base branch of the pull request, or `main` when the
   branch has no pull request:

   ```sh
   base=$(gh pr view --json baseRefName --jq .baseRefName 2>/dev/null \
     || echo main)
   git fetch origin "$base" main
   git rev-list --count "HEAD..origin/$base"
   ```

   A count above 0 shows that the branch is behind. Then merge the base
   branch with the `git-merge` skill. Push the merge, and watch the new
   commit. Then start this section again with the result of that watch. A
   rerun keeps the commit of its first run, so it cannot test a merge.

   After three such merges for one failure, use the last run. A busy base
   branch then cannot hold you in a loop.

2. A failure belongs to the branch when its job, step, test, or file is
   one that the diff adds or changes. A file counts only when the error is
   in its version on the branch. List the files of the diff:

   ```sh
   git diff --name-only "origin/$base...HEAD"
   ```

   Fix such a failure in the branch, as "When a test fails" in the
   `testing` skill says. Commit, push, and watch again. A flaky test that
   the diff adds or changes follows the flaky-test rule of the `testing`
   skill. A fix that needs a credential, a secret, or a runner waits for
   the user. Ask the user, with the failure text. After three failed fixes
   of one failure, ask the user, as the `testing` skill says.

3. Otherwise, rerun the failed jobs once with `gh run rerun <run> --failed`.
   Watch again.

   - A pass on the rerun makes the test flaky. An unrelated flaky test gets
     the follow-up item that the `testing` skill asks for. It gets no fix
     pull request.
   - Do not rerun it again, because more reruns hide a flaky test.
   - After a second failure, check the base branch again, as step 1 says.
     Then read the failing job on two fresh commits, `origin/$base` and
     `origin/main`. When the base is `main`, they are one commit.

     ```sh
     gh run list --commit "$(git rev-parse <ref>)" --workflow <workflow> \
       --event push --json databaseId,createdAt,conclusion
     gh run view <run>
     ```

     A pass counts only from a run of the job that started after the
     failed run of the branch. A pull request run of the base does not
     count, because it tests the base merged with another branch. Without
     such a run, run the failing command on that commit in a separate
     worktree. The failed step in the workflow file gives the command:

     ```sh
     git worktree add --detach <dir> <ref>
     git worktree remove <dir>      # after the run
     ```

   - When the job fails on both commits, the failure is unrelated. Fix it
     as [ci-fix.md](ci-fix.md) says.
   - When it fails on the base and passes on `main`, the failure comes from
     the base. Open no fix pull request. Make no fix in the branch. Report
     the red CI under **Open**, with both commits.
   - When it passes on the base, the failure belongs to the branch. Fix it
     in the branch, as step 2 says.

## Report

Under **Checks**, give each CI run of the last commit: the workflow, the
result, each rerun, and each fix commit.

- Report a run that still ran at the deadline as pending.
- Report a commit that has no run as "no CI run".
- Report a script that could not run, with its error.
- An unrelated failure gives its fix pull request, or the follow-up item
  that waits for the user.
- A red run that waits for a fix pull request, or for a fix in the base
  branch, also goes under **Open**.
- For CI that is not GitHub Actions, say that you cannot watch it.
