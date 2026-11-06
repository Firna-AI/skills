# Deleting a plan

The pull request of a change deletes its plan and its decisions file, so
that they do not stay on `main` after the work merges. The protocol docs
keep the decisions in force. The pull request description keeps the dated
record, and its permalinks keep the full files.

## When

The last two milestone TODOs of a plan delete it and open the pull
request. Do them when every other milestone TODO is ticked and the review
rounds are done. The tasks under `## Post-merge follow-up (non-blocking)`
are not milestone TODOs, so they do not hold back the deletion. Delete the
plan in the last commit before you open the pull request.

Keep the plan in these cases:

- The user asks for the pull request before the work is complete. Open
  it, and keep the plan. Delete the plan in the last commit of the work,
  when the condition above holds.
- The work spans more than one pull request. Each earlier pull request
  keeps the plan. The last one deletes it.

## Steps

1. Turn each unchecked post-merge task, and each open item of the plan or
   its decisions file that has no follow-up item yet, into a follow-up
   item. Follow "Writing an item" in [follow-up-items.md](follow-up-items.md).
   Read the whole entry and each entry that it names. Keep every fact.
   Merge an entry into the item of the entry that covers it.
2. Check that the protocol docs hold each decision in force. Move content
   that works as a doc, such as a roadmap, to its home under the
   `documentation` skill.
3. Search `docs/`, `plans/`, and every `README.md` for links to the plan.
   Remove each link.
4. Delete the plan and its decisions file, and name both in the commit
   message.
5. Write the pull request description with the `git-commit` skill. It
   gives each user decision and design call of the change, with its date.
   It links to each file that the change deletes, with a permalink at the
   commit before the deletion.

## After the deletion

- Record each decision that comes after the deletion in the pull request
  description.
- When large new work comes after the deletion, restore the plan and its
  decisions file from the commit before the deletion. Delete them again
  when the work is done.
- Do not delete a completed plan that is already on `main` without the
  user's approval.
