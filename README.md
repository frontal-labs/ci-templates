# frontal-labs CI templates

Shared GitHub Actions workflows for the frontal-labs org. One place holds the
logic. Other repos add a short caller that uses a versioned workflow from here.

## What's inside

- **Per-PR tools.** `upgrade-risk` runs on Dependabot and Renovate PRs.
  `pr-describe` runs on PRs opened by people.
- **Scheduled reports.** `top-pull-requests`, `top-issues` and the weekly
  `upgrade-risk` digest, posted to Slack.
- **Rollout.** `config/repos.json` lists which repo gets which tool.
  `scripts/sync-callers.sh` opens a PR in each one.

## Use it from another repo

Add `.github/workflows/frontal-pr-tools.yml` (see `callers/`) and it will be
synced for you. Or copy it yourself:

```yaml
jobs:
  tools:
    uses: frontal-labs/ci-templates/.github/workflows/pr-tools.yml@v1
    permissions: { contents: read, pull-requests: write }
    secrets: inherit
```

## Docs

- [Architecture](docs/ARCHITECTURE.md)
- [Onboarding: add a repo](docs/ONBOARDING.md)
- [Secrets](docs/SECRETS.md)
- [Runbook](docs/RUNBOOK.md)

## Development

```sh
actionlint .github/workflows/*.yml
shellcheck scripts/*.sh
GH_TOKEN=<token> scripts/validate-config.sh
```

Every PR runs these checks in `self-test`. Changes to this repo are released by
pushing a `v1.x.y` tag. See [CHANGELOG.md](CHANGELOG.md).

## License

MIT. See [LICENSE.md](LICENSE.md).
