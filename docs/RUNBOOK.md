# Runbook

What to do when a shared workflow fails. Start with the job's log, then the
symptom below.

## A report posted nothing, or the Slack post failed

- Check `REPORTS_POST`. If it is unset or not `true`, nothing posts by design.
- Look at the `slack-payload.json` artifact on the run. The workflow uploads it
  before posting, so you can inspect the payload.
- `curl --fail` returns an error on a non-2xx response. A revoked or rotated
  webhook shows up here. Recreate it and update the secret (see
  [SECRETS.md](SECRETS.md)).

## A report says a repo is missing or returns 404

- Confirm the repo is still in `config/repos.json` and not archived:
  `GH_TOKEN=<token> scripts/validate-config.sh`.
- Confirm `REPORTS_TOKEN` can read that repo. A fine-grained token only sees
  the repos it was granted.

## upgrade-risk does not run on a Dependabot PR

- The job runs only when the PR author is `dependabot[bot]` or `renovate[bot]`.
  Check `github.event.pull_request.user.login`, not who re-ran the job.
- Confirm `DEPENDABOT_TOKEN` exists in the Dependabot secret scope, not Actions.
- Fork PRs get no secrets, so the job skips them.

## pr-describe is slow or times out

- Each run downloads a model (about 1.1 GB) unless the `actions/cache` entry
  for that model is warm. Check the cache step.
- The job has a 25-minute limit. Large PRs read at most 32k tokens. Expect a
  long run on the largest frontal PRs before enabling `describe-update`.

## self-test fails on the pin check

- A new `uses:` line is not pinned to a 40-character SHA. Resolve the tag with
  `gh api repos/<owner>/<repo>/git/ref/tags/<tag>` and use the commit SHA,
  with the tag in a comment.

## A release did not move `v1`

- The tag must match `v1.*.*`. Check the release workflow run for the error.
- Do not move `v1` by hand. Fix the cause and push a new `v1.x.y` tag.
