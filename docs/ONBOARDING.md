# Onboarding: add a repo

A repo gets a tool by being listed in `config/repos.json` and then receiving a
caller PR from `scripts/sync-callers.sh`. Nothing else is needed in the target repo.

## Steps

1. **Pick the tool.** Add the repo name to the matching list in
   `config/repos.json`:
   - `prTools`: per-PR checks (upgrade-risk on Dependabot/Renovate PRs, pr-describe on human PRs)
   - `topPullRequests`, `topIssues`: scheduled Slack reports
   - `upgradeDigest`: weekly upgrade-risk digest (npm repos only)
2. **Validate.** Run `scripts/validate-config.sh` with `GH_TOKEN` set. It checks
   the schema and confirms the repo exists and is not archived.
3. **Open a PR here** with that change. CI must pass before merge.
4. **Sync callers.** After merge, run `scripts/sync-callers.sh --dry-run` and
   then `scripts/sync-callers.sh`. It opens a `ci/frontal-pr-tools` PR in each
   target repo. It never merges and never pushes to the default branch.
5. **Merge the caller PR in the target repo** (a human reviews it).
6. **Check the first run.** A Dependabot or human PR should show the expected
   check. See [RUNBOOK.md](RUNBOOK.md) if it does not.

## Rules for target repos

- Keep no copies of the logic. A caller file calls `pr-tools.yml@v1` and nothing else.
- The caller grants `pull-requests: write`. A called workflow can only lower
  the permissions it is given, never raise them.
- Use `secrets: inherit` so `DEPENDABOT_TOKEN` reaches the Dependabot run.
