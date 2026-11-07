# Secrets

Each secret is created once at the org level by a human. Nothing in this repo
stores a secret value. Never print one, not even in debug output.

| Secret | Kind | Access | Used by |
| --- | --- | --- | --- |
| `REPORTS_TOKEN` | Actions | Fine-grained token: read issues, PRs and code on every repo in `config/repos.json`. Also upgrade-risk, if that repo stays private. | Scheduled reports; `self-test` config check |
| `DEPENDABOT_TOKEN` | Dependabot | `pull-requests: write`. Set with `gh secret set DEPENDABOT_TOKEN --org frontal-labs --app dependabot`. | `upgrade-risk` on Dependabot PRs |
| `SLACK_WEBHOOK_TOP_PRS` | Actions | Incoming webhook for the top-PRs report | `report-top-prs` |
| `SLACK_WEBHOOK_TOP_ISSUES` | Actions | Incoming webhook for the top-issues report | `report-top-issues` |
| `SLACK_WEBHOOK_UPGRADE_DIGEST` | Actions | Incoming webhook for the upgrade digest | `report-upgrade-digest` |

## Why these details matter

- Dependabot runs get a read-only `GITHUB_TOKEN` and only see Dependabot
  secrets. `DEPENDABOT_TOKEN` must be set in the Dependabot scope, not Actions.
- Fork PRs get no secrets. Any job that needs `REPORTS_TOKEN` is gated to
  same-repo PRs and pushes.
- There is one Slack webhook per report because the payloads use fields that
  look like Slack Workflow Builder. A Workflow Builder webhook accepts a fixed
  set of fields. If the webhooks turn out to be ordinary incoming webhooks,
  the three can be merged into one.
- Posting to Slack is controlled by the repo variable `REPORTS_POST`. It starts
  unset, so nothing posts by default.

## Rotating a secret

1. Create the new token or webhook.
2. Update the org secret with `gh secret set <NAME> --org frontal-labs`.
3. Run `scheduled-reports` by hand with `post: false` to confirm it still works.
4. Revoke the old token.
