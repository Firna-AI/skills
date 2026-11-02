# Installer claims foreign update hooks

- **Severity:** Medium. **Likelihood:** Rare. **Effort:** Small. **Confidence:** High. **Harder later:** No.
- **Kind:** Outside the scope.
- **Added:** 2026-11-02, from branch `calummoore/coordinator-skill-design`, review round 2, the check of finding 54.
- **Location:** `scripts/install.sh`, the variable `hook_mark` and the jq function `ours` in `drop_hooks`. `tests/install_test.sh`, `test_hooks_keep_other_settings`.
- **Reason:** The same code is on `main`, and the branch that found it fixed only the role hook entries that it added.

- **Terms:**
  - **Hook entry:** one command under `hooks` in `~/.claude/settings.json`, which Claude Code runs at an event such as `SessionStart`.
  - **Mark:** the text that `scripts/install.sh` looks for in a hook command, to decide that it wrote the entry.
- **Background:**
  - `scripts/install.sh --hooks` adds the update hooks, which run `scripts/update.sh --hook`, to `~/.claude/settings.json`. It first drops each entry that it owns, so that a second run, or a run from a moved clone, keeps one entry. `--uninstall` drops the same entries.
  - It decides ownership with the mark `/scripts/update.sh" --hook`: each command that contains this text counts as its own.
  - On branch `calummoore/coordinator-skill-design`, the role hook entries got an explicit ownership marker in the command text, for the same reason: its review found that the installer deleted the role hook of another project.
- **Problem:** A hook of another project whose command contains `/scripts/update.sh" --hook` counts as owned. For example, `--hooks` and `--uninstall` both delete `"/opt/team/project/scripts/update.sh" --hook-mode stop`. Probes with an empty `HOME` confirmed this on `main` and on that branch.
- **Impact if no action:** The installer can delete a hook of another project from the user's settings, without a backup, and that automation stops.
- **Root question:** How does the installer recognise the update hook entries that it wrote, and only those?
- **Options:**
  - **A.** Give each update hook command an explicit ownership marker in its text, as the role hook entries have, and match only that marker. Keep the old mark only to replace the entries that an older install wrote, when their command is exactly `"<path>/scripts/update.sh" --hook --min-interval <n>`. Add a test with a foreign `update.sh --hook-mode` command. Effort: Small.
  - **B.** Match the full command of the old form exactly, with a pattern for the path and the interval, and no marker. It fixes the example, but a foreign command of the exact form still counts as owned. Effort: Small.
  - **C.** Write every hook entry through one helper that adds the marker, for the update hooks and the role hooks, so that a new hook kind cannot get a file-name match again. Effort: Medium.
- **Left out:** A backup of the settings file alone, because the foreign automation still stops. Change nothing, because the deletion stays.
- **Wider fix:** C. One helper owns the marker for each hook kind.
- **Previous examples:** On branch `calummoore/coordinator-skill-design`, the installer deleted a foreign `role-hook.sh` command for the same cause, and the branch fixed it with a marker. `plans/follow-ups/install-replaces-foreign-symlinks.md`, a related ownership failure for symlinks.
- **Recommendation:** C. It gives every hook entry the same explicit ownership, and A is its first step.
- **Action:** fix after merge, apply C, because the code is on `main` and outside the scope of the branch that found it.
