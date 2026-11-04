---
name: agents-md
description: Use when a repository has no AGENTS.md or CLAUDE.md, when its AGENTS.md or docs/dev rule files still carry General, Readme, Docs, Plans, Rust, Databases, Git, or Bash timeout sections, when a repository rule duplicates or conflicts with a shared skill, and when the user asks to create, migrate, slim down, or align a repository's agent rules with the shared skills.
---

# AGENTS.md

The target is an `AGENTS.md` of about 50 lines that holds only what is
specific to the repository. Everything general lives in the shared skills
and in the always-on global rules. The file does not list the shared
skills. An agent sees every skill's description, and the description says
when to read it. [templates/AGENTS.md](templates/AGENTS.md) is the template.

## New repository

1. Update the shared skills, as step 1 of the migration procedure says.
2. Copy the template from the updated skills to the repository root as
   `AGENTS.md`.
3. Fill every section. Delete each line and section that the template
   marks for deletion when the repository has none of that.
4. Create `CLAUDE.md` as a symlink to `AGENTS.md`.

## Section map for a monolith

| Monolith section | Now lives in |
| --- | --- |
| General: response style and reporting | the template's `## Communication` section, the global always-on rules, and `decisions-and-findings` |
| General: retries, file length, scratch output, safety | the global always-on rules |
| General: where application-, crate-, and feature-specific rules live | `documentation` |
| General: what to test, test levels, failing tests, removing tests | `testing` |
| General: targeted tests, smoke tests, gate, commit, push, review loop | `finish-work` |
| General: review format and auto-fix | `implementation-review`, with the layout in `decisions-and-findings` |
| General: flaky tests, no wall-clock assertions | `testing` |
| General: product data, copy, left-border rule | `product-ui` |
| Readme, Docs, Protocol Docs | `documentation` |
| Mockups | `mockups` |
| Plans | `plans` |
| Plans: the plan index `plans/README.md` and each plan whose work has merged | `plans`. See step 4 of the migration procedure |
| Rust and its subsections | `rust` |
| Databases | `databases` |
| Git: format, body length, examples, deletion audit, dead code, stale references, live and history | `git-commit` |
| Git: commit title length limit | nowhere; removed from `git-commit`, drop it |
| Git: mainline preservation during merge and rebase | `git-merge` |
| Bash Tool Timeout Configuration | nowhere; obsolete, drop it |

## Migration procedure

1. Update the shared skills before you compare rules with them. Get the
   latest commit of `futex-ai/skills` `main` with
   `git ls-remote https://github.com/futex-ai/skills.git refs/heads/main`.
   Bring the installed skills to that commit:
   - Skills linked from a clone of `futex-ai/skills`: run
     `./scripts/update.sh` in the clone. It fast-forwards a clean `main`
     and relinks the skills. Its `HEAD` must then be that commit.
   - Skills installed with `npx skills add`: run `npx skills update -g -y`.
   - Any other case, or a failed update: clone `main` under `.context/` and
     read the skills from that clone.
2. If step 1 brought a newer version of this skill, read that version.
   Read the repository's `AGENTS.md`, `docs/dev/*.md` if present, and
   `docs/implementation-review-prompt.md` if present. The shared skill text
   is the canonical version of every general rule.
3. Walk every rule and classify it:
   - **Covered**: the shared skill or the global file says the same thing.
     Drop it.
   - **Repository-specific**: commands, the agent-merge setting, paths,
     suite names, size caps and the lint that enforces them, link checks,
     generated directories, product locations and the shared UI library,
     review focus areas, production status. Keep it in the matching
     template section. A new `AGENTS.md` keeps the agent-merge setting
     `off` until the user turns it on.
   - **Package-specific**: a rule for `## Repository rules` that applies
     only to work on one application, package, or feature. Move it to the
     `README.md` next to its code, as the `documentation` skill says.
   - **Conflicting**: the repository says something different from the
     shared skill, for example an older plan index rule or an older review
     rule. The user decides.
   - **Uncovered general rule**: a rule that belongs in a shared skill but
     is not there yet. The user decides. Never drop it silently.
   - **Stale**: a rule that names a path, crate, command, or tool that the
     repository does not have, often because the rule file came from
     another repository. Drop it. When a shared skill holds the general
     part of the rule, only the named part is stale.
4. Find the plan files that the old plan rules made, and the repository
   docs that repeat a shared skill:
   - **Plan files**: the plan index `plans/README.md` and each plan whose
     work has merged. Delete them with the steps of "Deleting the plan" in
     the `plans` skill. Those steps turn each live item of a plan into a
     follow-up item first. The pull request description keeps the record
     of each deleted plan. An open plan stays and gets the status
     paragraph that the `plans` skill describes.
   - **Docs**: for example a file under `docs/dev/` or
     `docs/implementation-review-prompt.md`. Delete such a doc when
     nothing needs it. When code or a gate needs the file, such as a check
     that the file exists, cut it instead. A cut doc keeps only the
     repository facts and one sentence that points to the skill. A rule
     for work across the repository moves to `## Repository rules`, so
     that each fact lives in one place.
5. Search `docs/` and every `README.md` for each command or step that a
   conflict decision can replace. An example is an old review command
   that a doc gives as a completion step.
6. Send the checkpoint message described below and wait for the answers.
   The new `AGENTS.md` replaces content on `origin/main`, so change no
   tracked file in this repository before this checkpoint.
7. Write the new `AGENTS.md` from the template with the decisions applied.
   Fill every section. Move each package-specific rule to its `README.md`.
   Keep `CLAUDE.md` as a symlink to `AGENTS.md`.
8. Make the changes of step 4, except each entry that the user keeps.
   Delete each file whose deletion the user approved. Then search `docs/`,
   `plans/`, and every `README.md` for links to the deleted files. Update
   references in live content to name the skill instead of a deleted doc.
   Do not change the words of history. Replace a failing history link with
   a GitHub permalink, as the `git-commit` skill says.
9. A hit of step 5 needs a fix when a decision replaced its command or
   step. Fix such a hit in a `README.md` that is not a protocol doc in the
   same change. A change to a protocol doc also brings the cleanup that
   the `documentation` skill asks for when you touch the doc. So fix a hit
   in a protocol doc only when the doc has fewer than 250 lines and names
   no code. Otherwise record a follow-up item, as the `plans` skill says.
10. Run the repository's Markdown and link checks. Commit with the
    `git-commit` skill, for example
    `docs(agents): point AGENTS.md at shared skills`, and push.
11. Send the final report described below.

## Communicating with the user

The global always-on rules and the `decisions-and-findings` skill say how to
ask for decisions and how to report.
This task has one checkpoint message and one final report.

**The checkpoint message**, after classification and before any change:

- One line with the counts: rules covered, kept, moved, conflicting,
  uncovered, stale.
- One line with the `futex-ai/skills` commit from step 1.
- The repository-specific rules you will keep, grouped by template section,
  and the package-specific rules you will move, grouped by `README.md`.
  One line each. Do not quote the old file at length.
- The changes that need no decision, one line each. List each stale rule
  with the search that shows what is missing. List each file of step 4
  with its action and its evidence. The user's answer to the checkpoint
  approves this list, unless the user keeps an entry.
- Each hit of step 5, with its file and line.
- The numbered decisions. Every conflict, every uncovered rule, and every
  file deletion that step 4 does not cover is one decision. Give the
  repository's wording and the shared skill's wording when there is one.
  - A conflict offers: A, use the shared rule; B, keep the repository's rule
    as an override under `## Repository rules`; C, change the shared skill
    and apply it everywhere.
  - An uncovered rule offers: A, add it to a named shared skill with the
    proposed text; B, keep it as a repository rule; C, drop it.
  - A deletion offers: A, delete and update links; B, keep the file.
- A short list of what happens after the answers: write the file, move
  the package-specific rules, delete and cut the files, fix the hits,
  update links, run checks, commit, push.

**The final report**, after the commit, adds to the standard report:

- The line count of `AGENTS.md` before and after.
- The package-specific rules moved and the stale rules dropped.
- The plan files deleted, the docs cut or deleted, any other file
  deleted, and the links updated.
- The proposed shared-skill changes, with their text, so that the user can
  apply them in the skills repository.
