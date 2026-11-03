# The cycle in detail

This reference gives the commands and the detail of the `coordinator`
skill. `SKILL.md` gives the rules.

## Create a child

```sh
conductor --json project list --limit 100 --offset <n>
conductor --json workspace create --project-id <id> --branch main \
  --name "<change>" --agent <agent> --model <model> --effort <effort> \
  --message-file .context/coordinator/messages/<child>-1.md
```

- Find the project of the repository by its `gitRemote`. Step `--offset`
  while `hasMore` is true. Without a project, pass `--repo-url <url>`
  instead of `--project-id`.
- Take the agent, the model, and the effort from the
  `default orchestrator` action of the `models` skill. When the user
  named an agent or a model for this change, use it. Say so in the child
  prompt. Record it under the user instructions of the board.
- The command prints `workspaceId`, `sessionId`, and
  `initialMessage.messageId`. Record the three ids on the board, at the
  stage `new`.

## Send a message

```sh
conductor --json message create --session <orchestrator> \
  --message-file .context/coordinator/messages/<child>-<n>.md
```

- Write each message from `templates/messages.md` to a file under
  `.context/coordinator/messages/`.
- Record the `messageId` that the command prints as the last message of
  the child on the board.
- Send a message only when the table in `SKILL.md` allows a send. Put
  everything for the child into one message.

## Read a result

- The reader is `scripts/last-report.sh <session-id> <message-id>`. It
  reads the session status and the whole transcript. So run it at any
  status.
- The reader reads the latest request, also one that the user typed in
  the child. So a newer report can come for the same message id. Read
  each active child in each cycle. Act on its current result.
- The board stops a second action with three records: the stage of the
  child, each relayed item, and the retry record. The record of an item
  holds its state and its version. The retry record is in the next
  action of the child. Do not relay or raise an item again when it did
  not change. Do not send an answer again. Do not send a second retry for
  a request.
- The merge check runs again on the same final report in each cycle,
  until it passes, or until the pull request merged or closed. That is
  not a second action.
- The report of a child can say that the user answered one of its items
  there. Then mark that item closed on the board. Do not send the answer
  again.
- A final report has the labels of the final-report layout, such as
  **Changed**, **Decisions**, **Checks**, and **Open**. A question has
  numbered items with lettered options. Any other text is progress text.
- Give each design call of a child one line under **Decisions** in your
  report. Give each problem outside the scope of a child one line under
  **Open**.
- The `Updated` field of `conductor session status` is not the time of
  the last event. The age in the result of the reader is.
- A `waiting:` result from a workspace that slept is stale. The agent
  sends no task list when it starts again. The same tasks on the board
  from the last cycle show that the result is stale.

## Relayed items

"Items and answers" in `SKILL.md` says which items go to the user. The
"Open items" rules of the `decisions-and-findings` skill say which of
them your report gives in full, and which get one line under **Open**.

The board maps each of your numbers to the child and the child's own
number. It also records the version that the user saw: the date of the
child's report, and the child's sentence on the change. The first
version of an item has no such sentence. For your own item, your report
and your sentence give the version.

When you give an item in full, save its text in
`.context/coordinator/items/<number>.md`. A newer version replaces the
text. After a compaction, a re-print reads the item there.

The child gives a newer version when its report gives the item with a
sentence on the change that the board does not hold. The child also gives
one when a field that "Open items" names differs from the saved text. An
answered item that the child asks again is a newer version too.

Give the item in full again, with the sentence on the change. Record the
new version. The item is open again, also when the user answered it. The
same holds when you change one of your own items.

Before you send an answer, compare the version on the board with the
current report of the child. Make this comparison before you record a
newer version. When the item changed after the version that the user
answered, send nothing for it. Set its state to "open, answered <letter>
before the change". Give the changed item in full. Ask the user to
confirm the answer or to choose again.

## Stages

At each stage, relay the items of the child as "Relayed items" says.
Send the answers of the user as "Items and answers" in `SKILL.md` says.
When the board holds a pull request number, read its state first, as
"The state of a pull request" says. The other results of the reader get
the same action at every stage, as the table in `SKILL.md` says.

A final report or a question is new when it has an item, or a version of
an item, that the board does not hold. It is also new when it moves the
child to a later stage. Otherwise the board handled it.

| Stage | The child | On a new final report or question | On a result that the board handled |
| --- | --- | --- | --- |
| `new` | works on its first report | Root questions of a brainstorm: relay them. Then set `brainstorm`. A pushed plan that waits for approval: relay it. Then set `plan`. An open pull request: set `merge check`. | Nothing. |
| `brainstorm` | waits for the answers to its root questions | A pushed plan that waits for approval: relay it. Then set `plan`. An open pull request: set `merge check`. | Send the answers message when the user answers. Otherwise nothing. |
| `plan` | waits for the approval of its plan | A report that the user approved the plan in the child: set `implementing`. An open pull request: set `merge check`. | When the user approves, send the plan approval message. Then set `implementing`. When the user asks for changes, send them with the answers message. Otherwise nothing. |
| `implementing` | implements the plan, reviews it, and opens the pull request | A report with an open pull request: set `merge check`. | Nothing. |
| `merge check` | has an open pull request | Run the merge check. When it passes, merge, as "Merge and after" says. | The same: run the merge check again. Merge when it passes. |
| `merge queued` | has its pull request in the merge queue of GitHub | Read the pull request, as "A queued merge" says. | Read the pull request again, as "A queued merge" says. |
| `merged` | is merged and archived | Nothing. Drop the line one week after the merge. | Nothing. |
| `blocked` | waits for an item of the user, or for another child to merge | Check whether the blocker is gone. Then set the stage that the work needs. | The same. |

Relay a plan that waits for approval as one item. Its **Location** is the
plan file and the branch. Option A approves the plan. Option B approves
it with the changes that the user names. Option C stops the change.

## Errors and retries

- A refusal, a usage limit, an input limit, and a missing or revoked
  credential are blocks, as the `delegating` skill says. Raise the item
  at once, with no retry. Quote the error. Give its reset time when it
  has one. Only the user can override the action of the child.
- A session is lost when its error says that its thread or its session
  is gone, such as "thread not found". Start one session in the workspace
  of the child with `conductor session create --workspace <id>`, the
  `default orchestrator` action, and the new orchestrator prompt. Record
  its id as the orchestrator.
- Cancel a stalled session with `conductor session cancel <id>`. Then
  send the retry message in the same cycle. After a cancel, the
  transcript keeps the running state. So the reader prints
  `pending: working` for up to 30 minutes.
- Send the retry message once for each other error.
- After the one retry, a new error or a request without a final report or
  a question is a failed retry. A stream disconnect, such as a
  `turn.failed` after "Reconnecting... 5/5", counts too. Raise an item.
- A child that stopped with work that is not committed gets the status
  request or the retry message. Never finish its work yourself.

## The state of a pull request

Read the state of the pull request first at each stage where the board
holds its number. The stage `merged` needs no read. The merge check and
"A queued merge" read the state in their queries. At another stage, such
as `blocked`, read it with the `gh pr view` query of "Merge and after".

Read the merge fields, `mergeable` and `mergeStateStatus`, only when the
state is `OPEN`. A merged pull request reads `UNKNOWN` there. A closed
one can read `CLEAN`.

| The state | Do this |
| --- | --- |
| `OPEN` | Act by the stage. |
| `MERGED`, below the top of a stack | Act as "A stack of pull requests" says. |
| `MERGED`, any other pull request | Act as "After the merge" says. Then set `merged`. |
| `CLOSED` | Someone closed the pull request without a merge. Raise one item. Then set `blocked`. |

## The merge check

`<owner/repo>` comes from the board. `gh api` takes it in its path or its
variables.

| Condition | Read it with |
| --- | --- |
| The state, the draft, and the merge state | `gh pr view <n> --repo <owner/repo> --json state,mergeCommit,headRefName,isDraft,mergeable,mergeStateStatus,headRefOid`. Read the state first, as "The state of a pull request" says. |
| The final report | The last report of the child. The report also gives the merge method from `AGENTS.md`. |
| The required checks | `gh pr checks <n> --repo <owner/repo> --required`. "no required checks reported" means that the branch has none. |
| The other checks | `gh pr checks <n> --repo <owner/repo> --json name,bucket,workflow`. |
| A check on `main` | `gh run list --repo <owner/repo> --branch main --workflow <workflow> --status completed --limit 1`, then `gh run view <run> --repo <owner/repo> --json jobs`. |
| The diff | `gh pr diff <n> --repo <owner/repo>` and `gh pr view <n> --repo <owner/repo> --json files`. Read every changed line. |
| The items | The relayed items on the board. |

A check fails on `main` too when its job failed in the latest completed
run of its workflow on `main`. When `main` has no completed run of that
workflow, the check did not fail on `main`.

| The merge check finds | Do this |
| --- | --- |
| A check that still runs, or the merge state `UNKNOWN` | Nothing in this cycle. |
| A report that does not say complete and reviewed, or a draft | Send the fix request. |
| A defect in the diff, or a file outside the scope of the child | Send the fix request, with the line and the fact that shows the defect. |
| A required check that fails for a cause outside the change, and an open fix pull request for it that the child names | The merge check waits for the fix pull request. Name the fix pull request under **Open**. While it is open, no other row on a failed check or on the merge state `BLOCKED` applies to this check. So raise no item for the check in that time. |
| A check that fails only on the branch | Send the fix request once. When the child shows a cause outside the change, in a report or after the fix request, raise an item. |
| A check that is not required and fails on `main` too | The condition holds. Name the check in the report. |
| A required check that fails on `main` too, or the merge state `BLOCKED` with no check that runs | Raise an item. |
| The merge state `DIRTY` or `BEHIND` | Send the merge-main message. |
| An open item of the change | Wait for the answer of the user. |

## Merge and after

```sh
gh pr merge <n> --repo <owner/repo> --squash --match-head-commit <headRefOid>
gh pr view <n> --repo <owner/repo> --json state,mergeCommit,headRefName
```

- Use the merge method that the `AGENTS.md` of the repository names, or
  `--squash`. Do not add `--delete-branch`. In a repository with a merge
  queue, `gh` refuses that flag. So it sends no merge.
- `--match-head-commit` stops the merge when the child pushed after your
  check. A refusal that names a merge state, such as `BEHIND`, `DIRTY`,
  or `BLOCKED`, means that `main` moved. In both cases, check again in
  the next cycle.
- Raise each other error of the merge command as an item that quotes
  the error. Examples are a ruleset error and a permission error.
- After the merge command, read the state with the `gh pr view` query
  above. On `OPEN`, GitHub queued the pull request. Set `merge queued`.
  Read the pull request again in the next cycle. Act on `MERGED` and
  `CLOSED` as "The state of a pull request" says.

### A queued merge

`gh pr view` has no field for the merge queue. At the stage
`merge queued`, read the pull request in each cycle with this query:

```sh
gh api graphql -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){pullRequest(number:$n){state isInMergeQueue}}}' -f o=<owner> -f r=<repo> -F n=<n>
```

| The query shows | Do this |
| --- | --- |
| `MERGED` or `CLOSED` | Act as "The state of a pull request" says. On `MERGED`, first run the `gh pr view` query of "Merge and after". It gives `mergeCommit` and `headRefName`. |
| `OPEN`, and `isInMergeQueue` is true | Nothing in this cycle. |
| `OPEN`, `isInMergeQueue` false, and a removal event after your merge command | The queue removed the pull request. Set `merge check`. Run the merge check. When it passes, raise an item that quotes GitHub's reason. Do not merge until the user answers that item. So the pull request does not go back into the queue in each cycle. |
| `OPEN`, `isInMergeQueue` false, and no such removal event | GitHub waits to add the pull request to the queue. Nothing in this cycle. |

The last removal event of the pull request gives GitHub's reason, such
as `failed_checks`:

```sh
gh api graphql -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){pullRequest(number:$n){timelineItems(last:1,itemTypes:[REMOVED_FROM_MERGE_QUEUE_EVENT]){nodes{...on RemovedFromMergeQueueEvent{createdAt reason}}}}}}' -f o=<owner> -f r=<repo> -F n=<n>
```

### After the merge

```sh
gh api -X DELETE repos/<owner>/<repo>/git/refs/heads/<headRefName>
conductor workspace archive <workspaceId>
```

- Delete the branch of the pull request. A 422 or a 404 with
  "Reference does not exist" means that GitHub deleted it already. Raise
  each other error of the delete as an item that quotes the error.
- Archive the child. The archive also closes the sessions of the child.
- Send the merge-main message to each child whose pull request or plan
  touches a file that the merge changed.
  `gh pr view <n> --repo <owner/repo> --json files` lists the files of a
  pull request. The `mergeCommit` is the commit that the message names.
- In the report, name the follow-up items that the pull request adds.
  Its description lists them. The `finish-work` skill asks for this
  after each merge.

## A workspace that the user hands over

1. Record the workspace on the board, at the stage `new`. Take its
   repository and its name from `conductor --json workspace get <id>`.
2. Take the orchestrator session that the user names. When the user names
   none, take the first session that `conductor workspace session <id>`
   lists. Name it in the report. A workspace without an open session gets
   a new orchestrator, as "Errors and retries" says.
3. Read the session with the reader. When the table in `SKILL.md` allows
   a send, send the handover message.
4. Set the stage from its report:
   - root questions of a brainstorm: `brainstorm`,
   - a pushed plan that waits for approval: `plan`,
   - work in progress: `implementing`,
   - an open pull request: `merge check`.

## A stack of pull requests

A child can open a stack with `gh stack`: pull requests that build on
each other. Only the bottom pull request targets `main`.

- Run the merge check when the report of the child gives the whole stack.
- Merge from the bottom, one pull request at a time.
- After each merge below the top, do the steps of "After the merge" for
  its pull request. Do not archive the child yet. Send the stack message.
  Set `merge check`. Check the next pull request in a later cycle.
- After the top pull request merges, the child gets "After the merge"
  and `merged`, as "The state of a pull request" says.

## The archive

- Archive a child after its merge, or when the user asks for it.
- Do not archive a child at the stage `blocked` before its pull request
  merges, unless the user asks for it.
- An archived workspace stays restorable. Record each archive in the log
  of the board.
