# Callers

Files in this folder are copied into other org repos. Each caller is a short
workflow that calls a versioned reusable workflow in this repo. Target repos
never copy the logic.

| File | Copied to | Calls |
| --- | --- | --- |
| `frontal-pr-tools.yml` | `.github/workflows/frontal-pr-tools.yml` in each repo listed under `prTools` | `pr-tools.yml@v1` |

## Rules

- The first line after the header is a managed-by comment. Edit the file here,
  never in the target repo. The next sync overwrites target-repo edits.
- The caller grants `pull-requests: write`. A called workflow can only lower
  permissions it is given.
- Use `secrets: inherit` so `DEPENDABOT_TOKEN` reaches the Dependabot run.
- Rollout happens through `scripts/sync-callers.sh`, which opens a PR in each
  target repo. Changes go through PRs only.
