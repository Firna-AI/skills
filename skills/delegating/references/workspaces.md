# Workspaces

A workspace is a checkout on its own branch, on its own machine or in
its own worktree, where one agent does one work item. In Conductor,
each workspace is a Conductor workspace. [conductor.md](conductor.md)
gives its commands. Without Conductor, a worktree agent, a second
machine, or a cloud session follows the same procedure. A worktree
agent here is a workspace agent in a worktree. It pushes its branch and,
when its work item is complete or the user asks, opens a pull request,
unlike a worktree subagent.

The orchestrator runs the procedure from the primary workspace, on the
primary branch. It keeps a ledger under
`.context/<plan-name>/workspaces.md`. The ledger lists the item, the
ids, the action, the branch, the pull request, the review round, and the
state. The prompts and the reports go under `.context/<plan-name>/` too.

## Start a work item

1. Write the prompt from the workspace prompt template. Save it under
   `.context/<plan-name>/prompts/<item>.md`.
2. Create the workspace on the primary branch, with the
   `default orchestrator` action from the `models` skill. Name it
   `<plan-name>: <item>`. Give it the prompt as its first message. The
   prompt names the action that does the item. When the tool does not
   create the branch, create it from the primary branch and name it for
   the item.
3. Record the workspace, its session, the action, and the branch that
   the agent reports in the ledger.

A new workspace gets the skills from the repository's setup script.
Codex has no update hook, so that script runs the update script before
the install script.

## Read the result and request changes

The agent reports in its session. Read its first message for the
branch. Then read its report, as [conductor.md](conductor.md) says, and
its pull request, when it opened one.

You run the review of the item's branch, so you keep its findings file,
as the `implementation-review` skill says. Send a fix request as one
message with the text of each `fix now` finding and the option to apply.

## Integrate and close

```sh
git fetch origin <branch>
git merge --no-ff origin/<branch>
# run the merge audit and the complete gate first
git push origin <primary-branch>
```

Merge the branch on the primary branch when its review is done, also
when findings stay open. Merge it again after each fix round. Directly
after each merge commit, run the merge audit from the `git-merge` skill.
Run the complete gate from `AGENTS.md`, then push. With a pull request
that is already open and whose CI runs the gate, push and let CI run
it, as the `finish-work` skill says. Never open a pull request to make
CI run the gate.

After the last merge, close the work item. First confirm that each TODO
of the work item is ticked, as step 3 of "Check, merge, and continue" in
the `delegating` skill says. Then:

```sh
git fetch origin <branch>
sha=$(git ls-remote origin refs/heads/<branch> | cut -f1)
git merge-base --is-ancestor "$sha" HEAD
# only with a pull request whose state is OPEN
gh pr close <number> --comment "merged into <primary-branch> at <merge sha>"
git push --force-with-lease="refs/heads/<branch>:$sha" origin --delete <branch>
```

`git ls-remote` reads the live head of the branch. Confirm that the
primary branch holds it. When it does not, or git reports an unknown
commit, the branch moved after your merge. Review and merge again. The
lease deletes the branch only while it still points to the checked
commit. A `stale info` rejection means that the branch moved after the
check. Reopen a pull request that you closed, then review and merge
again.

With a pull request, `gh pr view <number> --json state` gives its state.
GitHub may not mark a pull request into a branch other than the default
as merged. When the state stays open, close the pull request with a
comment that names the merge commit. For a branch that the user agreed
to abandon, skip the ancestor check. Lease the delete to the commit that
the user agreed to abandon.

Delete the branch on the remote. Archive the workspace with its tool.
Mark it closed in the ledger. The merge commit keeps the content of a
merged branch, so its deletion needs no approval. The content of an
abandoned branch is in no merge, so the abandon is a decision for the
user.

The primary branch's pull request into `main` deletes the plan, as the
`plans` skill says. When that pull request merges, delete the primary
branch and archive the primary workspace.
