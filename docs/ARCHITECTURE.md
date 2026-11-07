# Architecture

## Two kinds of workflow

- **Reusable workflows** (`on: workflow_call`) sit directly in
  `.github/workflows/`. Other repos call them. GitHub only finds reusable
  workflows in that folder. They never copy logic from here.
- **This repo's own workflows** (`scheduled-reports.yml`, `self-test.yml`,
  `dogfood.yml`, `release.yml`) run here only.

## Flow

```
target repo PR ──► caller (callers/frontal-pr-tools.yml)
                     └─► pr-tools.yml@v1
                          ├─ Dependabot/Renovate author ─► upgrade-risk.yml ─► frontal-labs/upgrade-risk@v1
                          └─ human author (same repo)   ─► pr-describe.yml  ─► frontal-labs/pr-describe@v1

schedule (weekdays / Mondays) ─► scheduled-reports.yml
  ├─ reads config/repos.json
  └─► report-top-prs / report-top-issues / report-upgrade-digest
        ├─ checks out the tool repo at tool-ref
        ├─ runs the tool, writes slack-payload.json
        ├─ uploads it as an artifact
        └─ posts to Slack only when post is true
```

## Versioning

- Release tags are `v1.x.y`. `release.yml` moves the `v1` tag to the same
  commit and creates a GitHub Release from `CHANGELOG.md`.
- Callers pin `@v1`, so a fix ships by moving the tag. Breaking changes
  get a new major tag.
- The tool repos (`upgrade-risk`, `pr-describe`, `top-pull-requests`,
  `top-issues`) have no tags yet. Reports use `tool-ref: main` until they do.

## Safety defaults

- `permissions: {}` at workflow level. Each job grants only what it needs.
- Every job has a `timeout-minutes`.
- Every third-party action is pinned to a commit SHA. `self-test` checks this.
- Anything that posts to Slack or edits PRs is off until a human turns it on.
- Fork PRs get no secrets and are skipped by any job that needs them.
- The `pull_request` author is checked, never `github.actor`.
