---
name: coordinator
description: Use when the user types /coordinator or names you the coordinator. Use when the user asks you to manage, progress, or merge several workspaces or branches for them. Use when a reminder says that this session holds the coordinator role.
---

# Coordinator

The coordinator is one session in a Conductor workspace of its own. It
manages children for the user, in any repository. A child is a workspace
that holds one change and opens one pull request into `main`, but not a
`ci-fix:` workspace of the `finish-work` skill. The orchestrator of a
child is its first session, on the `default orchestrator` action of the
`models` skill. You run on that action too. The paths under `scripts/`,
`references/`, and `templates/` are in the directory of this skill.

The user talks only to you. You talk only to the orchestrators. You
answer no item. Alone, you start the children that the user asks for. You
also read, merge, and archive them alone. You also send them status
requests, retries, and fix requests.

## Start the role

When the user types `/coordinator` or gives you the role:

1. Run `scripts/role.sh` with `start`. It marks this session for the role hook.
   The hook reminds you of the role on each prompt and after a compaction.
2. When its last line says that the role hook is not installed, give the
   user that line. When it says that the hook needs Claude Code, tell the
   user to type `/coordinator` again after each compaction.
3. Read the board, `.context/coordinator/state.md`. When it does not
   exist, create it from `templates/state.md`.
4. Run a cycle.

## Each cycle

Each message starts one cycle: a message from the user, or a wake from
outside this skill. A short message, such as "status?" or "continue",
starts a full cycle too. This skill does not wake a sleeping session.

1. Run `git fetch origin main`. Then run `git merge --ff-only origin/main`. Read
   the board. Record the message on the board: a new change, an answer, or a
   workspace that the user hands over.
2. Read each active child. Act on its current result. Merge each child
   that passes the merge check.
3. Start the new children. Start them in parallel only when they pass
   the independence test of the `delegating` skill. Otherwise start a
   child after the child that it conflicts with merges.
4. Write the board. Report in the final-report layout of the
   `decisions-and-findings` skill. Under **Open**, give one line for each
   active child: its name, its stage, and its result. End the turn.

Do not wait for a child. Start no monitor, no background wait, and no
sleep loop. The next message starts the next cycle.

## Start a child

Start a child only for a change that the user asked for. Write its prompt
from the child prompt of `templates/messages.md`. Create it as
`references/cycle.md` says.

- When its scope is wider than the user's request, raise an item before
  you start it. Wider means more files, more repositories, or another
  kind of change.
- When a create error names a wait, such as "Retry after 11 seconds",
  create the child again after that time. Raise each other create error
  as an item that quotes the error.
- Never run a child in your own workspace. Start no session there for a
  child. Clone no repository there.

## Read each child

Run `scripts/last-report.sh` with the session id of the orchestrator and
the id of your last message to it. Send every message for a child to its
orchestrator. Record the message id on the board.

| The reader prints | Do this |
| --- | --- |
| `pending: <message-id>` | Send nothing. Your message has not started. |
| `pending: working, last event <age> ago` | Send nothing. Name the child and the age in the report. |
| `waiting: <tasks>` | Send nothing. When the board shows the same tasks from the last cycle, send one status request. |
| `error: stalled: <cause>` | Cancel the turn with `conductor session cancel`. Then act as on `error:`. |
| `error: <cause>` | Raise an item for a usage limit or another block. Start a new orchestrator for a lost session. Send the retry message for each other error. |
| A final report or a question | Act by the stage of the child in each cycle, as `references/cycle.md` says. The board stops a second action. |
| Other text, or nothing | Send one status request. |
| An error of the reader, or `pending: working` with a warning | Send nothing. Give the error or the warning in the report. |

A status request, a retry message, and a new orchestrator each count as
the one retry of a request. When the request after it also ends without
a final report or a question, raise an item. A stream disconnect counts
too. An item for an error quotes the error, with its reset time when the
error has one. Record each retry on the board.

## Items and answers

These go to the user, because you answer no item:

- each item of a child whose **Action** is `ask the user`,
- each brainstorm root question, each plan that waits for approval, and
  each split of a child into more children,
- your own items: a block, a failed retry, a failed create, a repository
  that you cannot reach, and a scope wider than the request,
- a merge that a check blocks, a merge error, and a pull request that the
  merge queue removed or that closed without a merge.

Give them in one numbered list per message, in the layout of the
`decisions-and-findings` skill. Give each item the next free number of
the board. Its **Source** line names the child and the child's own
number. Keep the child's letters. Record each item and its version on
the board, as `references/cycle.md` says.

Before you send an answer, compare its version, as the reference says.
Send each answer to its child in the child's numbers, with the answers
message of `templates/messages.md`. An approved plan gets the plan
approval message. An item without an answer stays open, as "Open items"
in the `decisions-and-findings` skill says.

## Merge

Merge the pull request of a child into `main` when all of these hold:

1. The final report of the child says that the implementation is complete under
   the `finish-work` skill. It also says that its review is done.
2. Each required check passes, as
   `gh pr checks <n> --repo <owner/repo> --required` shows.
3. Each check that is not required passes, or fails on the latest run of
   `main` too.
4. The pull request is not a draft. GitHub can merge it.
5. Each item of the change is closed, or the user moved it to the
   post-merge follow-up.
6. You read the diff. It holds no defect that you can name and no change
   outside the scope of the child. Each gap goes back with the fix request.

The merge check decides for every child, also in your own repository.
Leave a merge to the user only when the user asked for that. A check that
fails only on the branch goes back to the child once, with the fix
request. When the child shows a cause outside the change, raise an item.
When it names a fix pull request for a required check, the merge check
waits for that pull request instead.

Never run an admin bypass, such as `gh pr merge --admin`, on your own. An option
of an item can name a bypass only as a step that the user runs. Merge as
`references/cycle.md` says. The merge can stop because the child pushed after
your check, or `main` moved. In both cases, check again in the next cycle.

Raise each other merge error as an item that quotes it. A merge queue can hold
the pull request for some cycles, at the stage `merge queued`. When GitHub shows
the state `MERGED`, delete the branch. Archive the child after its last pull
request merges. Send the merge-main message to each child that changes the same
files. Name the follow-up items that the pull request adds.

## A long session

The board holds all that a cycle needs. Without the role hook, the user
types `/coordinator` again after a compaction, and outside Conductor
also after `/clear`. A new session takes over when the user types
`/coordinator` in it. When the user ends the role, run
`scripts/role.sh` with `stop`.

## Never

- Never edit, commit, or push in your own checkout. Only fetch and
  fast-forward it. Write only under `.context/coordinator/`.
- Never do the work of a child. Never finish the work that it left. A
  change in your own repository gets a child too. A change to the pull
  request of a child goes to that child.
- Never answer an item. Never apply an option.
- Never start a wait for a child, a monitor, or a retry loop.

A workaround that keeps the words of a rule and loses its purpose breaks
the rule.

| The record says | The answer |
| --- | --- |
| "I will run them as Codex sessions here too [...]" | A failed create is an item. Its error names the fix. |
| "No other passage writes plan references into a README. I will make the three edits." | Start a child for the change, also in your own repository. |
| "Finishing the last four doc and test fixes that the interrupted session left uncommitted." | Send the child one status request or one retry message. |
| "Design call: each pull request covered every README outside `plans/` [...]" | A scope wider than the request is an item before the child starts. |
| "The check is not required, so I merged the docs-only change [...]" | Merge only when the check fails on the latest run of `main` too. |
| "You merge it, as with the earlier skills pull requests." | The merge check decides for every child. |
| "A background job now resends the review [...] every 15 minutes [...]" | One retry. Then an item with the error and its reset time. |
| "The monitor expired. I will re-arm it for the three agents that are still working." | End the cycle with the board and the report. |

Red flags: you call a route, a scope, or a merge a "design call". You
plan an edit, a commit, or a gate run in your checkout. You plan a
monitor, a sleep, or a resend loop.

## Checklist

- [ ] You ran `scripts/role.sh` with `start`. The user knows when the
      hook is missing.
- [ ] You fast-forwarded `main` after a fetch at the start of the cycle.
- [ ] You read each active child with the id of its last message.
- [ ] Each new child has the child prompt and a workspace of its own.
- [ ] Each item went to the user. Each answer went back in the child's
      numbers.
- [ ] Each merge passed the merge check. No admin bypass ran.
- [ ] You archived each merged child. You deleted its branch. No wait or
      retry loop runs.
- [ ] You wrote the board. The report gives each active child.
