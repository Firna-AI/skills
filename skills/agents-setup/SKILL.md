---
name: agents-setup
description: Use when a repository has no .agents/setup, when the user asks to set up a repository for Amp orbs or to align or speed up its .agents/setup, when an orb setup is slow or misses a tool, and before you add sccache, RUSTC_WRAPPER, or another build cache to a setup script or to the Amp env vars.
---

# Agents setup

An Amp orb runs `.agents/setup` to install what a repository needs. Amp
saves the result in a snapshot, and new orbs start from that snapshot.
This skill gives the shared rules for that script. Amp's built-in
`orb-setup` skill gives the lifecycle: when setup and resume run, the
time limits, and the snapshot rules. Read the `orb-setup` skill first.
When it is not installed, read https://ampcode.com/docs/orbs.
[templates/setup](templates/setup) is the skeleton.

## 1. Read before you write

- Read the CI workflows. CI is the reference for the toolchain pins, the
  build flags, the browser channel, and the system packages.
- Read the pin files, for example `.nvmrc`, `rust-toolchain.toml`, the
  `packageManager` field, and `.bun-version`. The script reads each
  version from its pin file. Do not copy a version into the script.
- Read the gate named in `AGENTS.md`. Setup prebuilds what the gate needs.
- Read the project scripts with `amp projects get <project>`. Prefer a
  committed `.agents/setup`. Use the pre-setup script only when the user
  does not want Amp files in the repository.
- When `.agents/setup` exists, go to section 4 first.

## 2. The rules

- **Shape.** Start from the template. Time each step with the `step`
  function, so that `~/.cache/amp/logs/setup.log` shows the slow step.
- **Idempotent.** Each install checks first and skips when the right
  version is there. Run the script twice. The warm run downloads nothing.
- **Downloads.** Pin each binary download to a version and check its
  SHA-256 against the checksum file of the release.
- **Environment.** Write the toolchain paths and the build variables to
  one environment file. Setup rewrites that file on each run. Add one line
  to `~/.bash_profile` that sources it, and add it only once. Amp and the
  supervised services start in login shells that read that file.
- **No build variables in Amp settings.** Do not put `RUSTC_WRAPPER`,
  `PATH`, or another build variable in the personal or workspace env vars
  of Amp. Those reach every orb of every repository, also orbs that do not
  have the tool. Put them in the environment file of the repository.
- **Secrets.** Read tokens and remote cache credentials from Amp secrets
  or project env vars. Never write them in the script. Never sign in
  during setup.
- **Shared skills.** Clone `futex-ai/skills` into `~/.futex/skills`, or
  update the clone with its `update.sh`. Run its `install.sh --quiet`.
  Link its `global/AGENTS.md` to `~/.config/AGENTS.md`, which Amp reads.
  Do not link `~/.config/amp/AGENTS.md`; the orb image owns that file.
- **Skip.** Do not install the Codex or Claude Code CLIs. Do not add
  `.agents/resume` unless something must sign in or reconnect when an orb
  wakes.
- **Prebuild for the snapshot.** Install the dependencies, build, and
  compile the test binaries, so that a new orb starts warm. Time a slow
  optional tool, such as a security audit binary. Prebuild it only when
  the gate needs it on each run.
- **Rust.** When CI builds without debug info, set
  `CARGO_PROFILE_DEV_DEBUG=0` and `CARGO_PROFILE_TEST_DEBUG=0`. A debug
  test build of a large workspace can fill tens of GB. Keep incremental
  builds on, also when CI sets `CARGO_INCREMENTAL=0`.
- **Git.** Fetch the full history and the tags only when the gate or a
  test reads them. When tests commit in their own repositories with their
  own identity, Amp's commit signer rejects those commits. Turn signing
  off for that directory only, with an `includeIf` that points to
  `/etc/gitconfig.d/amp-signing-off`.
- **Browsers.** Install the browser that CI uses, for example Playwright
  Chromium. Run its system-package install only when `ldd` reports a
  missing library.
- **Time.** Aim for a cold run under 2 minutes. A longer cold run is
  acceptable only when the snapshot covers most new orbs. Report the cold
  time and the warm time.

## 3. Caches: measure first

A cache, such as sccache, a dependency fingerprint, or a marker file, is
not a default. The snapshot already keeps the build output and the
package caches warm. Add a cache only when measurements show a gain.

1. Measure the cold build without the cache: a fresh target directory,
   for example `cargo build --target-dir /tmp/cold-a`. Note the CPU count
   of the orb.
2. Measure the warm setup run. Most new orbs see this case.
3. Measure the cold build with the cache, twice. The first run fills the
   cache. The second run, in another fresh target directory, reads it.
   Record the hit rate, for example with `sccache --show-stats`.
4. For a remote cache, such as S3 or R2, measure the same runs. Each
   cache read and write waits for the network.
5. Keep the cache only when step 3 or 4 is clearly faster than step 1.
   Otherwise comment out the install step and the variable that turns
   it on. Add a comment with the measurements and how to turn it back on.

sccache has extra rules:

- sccache does not cache incremental builds. With sccache on, set
  `CARGO_INCREMENTAL=0`. Measure the rebuild time after a small edit with
  and without it. Report the cost.
- Set `RUSTC_WRAPPER` only in the environment file, as section 2 says.
- A local cache needs no credentials. A remote cache needs the bucket
  variables and a secret in Amp settings.

Example from a Rust workspace on a 2-CPU orb: the cold build took about
4 minutes without sccache. An R2 cache took 7m47s cold and 4m48s warm,
with 91% hits. The cache made the build slower, so the step stays
commented out. Incremental rebuilds took 4.7 s, against 11.0 s with
`CARGO_INCREMENTAL=0`.

## 4. Align an existing setup

The current script is functionality on `origin/main`. Do not remove or
change a step without the user's approval.

1. Walk each rule of sections 2 and 3, and classify the script:
   - **Matches**: no change.
   - **Missing**: add it, for example the step timer, the checksum, or
     the shared skills step.
   - **Differs**: the script does something else, for example an
     unmeasured cache, a build variable in Amp settings, or a CLI install.
     Each one is a decision for the user.
   - **Repository-specific**: a step that no rule covers. Keep it.
2. Measure what a decision needs, such as the cache runs of section 3.
3. Send one message with the counts, the missing items you will add, and
   the numbered decisions with their measurements. Wait for the answers.
4. Apply the answers. Then verify as section 5 says.

## 5. Verify

- Run `.agents/setup` cold and then warm. Both runs exit 0. Record both
  times and the slowest steps.
- Check the environment from a clean login shell in the repository root,
  for example `env -i HOME="$HOME" /bin/bash -lc 'command -v cargo'`. Do
  not source the profile into your own shell. Do not print the full
  environment.
- Run the gate named in `AGENTS.md` from a clean login shell.
- Run `bash -n` and `shellcheck` on the script.

## 6. Finish

- Make the script executable. Add `.amp/portals/*` to `.gitignore` when
  no rule covers it.
- Commit with the `git-commit` skill, for example
  `chore: add Amp orb setup script`. Put the cache measurements in the
  body.
- A local commit does not change new orbs. Setup is active only after
  the commit reaches the default branch. Say so in the final report.

## Checklist

- [ ] The `orb-setup` skill, the CI workflows, and the pin files are read.
- [ ] Each version comes from a pin file. Each download has a checksum.
- [ ] The environment file holds the build variables. Amp settings hold
      no build variable.
- [ ] The shared skills step and the `~/.config/AGENTS.md` link exist.
- [ ] Each cache has measurements, or it is commented out with them.
- [ ] Each change to an existing step was a decision of the user.
- [ ] Cold and warm runs passed, with their times in the report.
- [ ] The gate passed from a clean login shell.
