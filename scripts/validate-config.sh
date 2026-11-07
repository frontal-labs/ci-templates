#!/usr/bin/env bash
# Checks config/repos.json: required keys, string lists, no duplicates,
# and (unless --offline) that every repo exists in the org and is not archived.
#
# Usage: scripts/validate-config.sh [--offline] [path/to/repos.json]
# Needs GH_TOKEN for the online check. The token is never printed.
set -euo pipefail

OWNER="frontal-labs"
OFFLINE=0
CONFIG="config/repos.json"

for arg in "$@"; do
  case "$arg" in
    --offline) OFFLINE=1 ;;
    *) CONFIG="$arg" ;;
  esac
done

if [[ ! -f "$CONFIG" ]]; then
  echo "error: $CONFIG not found" >&2
  exit 1
fi

fail=0

# Structural checks. Each key must be an array of unique, non-empty strings
# made of letters, digits, dots, underscores or hyphens.
structure_errors=$(jq -r '
  . as $root
  | def repo_list(k):
      if ($root[k] | type) != "array" then "\(k): must be an array"
      elif ([$root[k][] | type] | any(. != "string")) then "\(k): every entry must be a string"
      elif ([$root[k][] | select(test("^[A-Za-z0-9._-]+$") | not)] | length) > 0 then "\(k): invalid repo name"
      elif (($root[k] | length) != ($root[k] | unique | length)) then "\(k): duplicate entries"
      else empty end;
  (["prTools", "topPullRequests", "topIssues", "upgradeDigest"][]
    | . as $k
    | if ($root | has($k) | not) then "\($k): missing" else repo_list($k) end),
  ($root | keys_unsorted[]
    | select(. as $k | ["$schema","prTools","topPullRequests","topIssues","upgradeDigest"] | index($k) | not)
    | "unknown key: \(.)")
' "$CONFIG")

if [[ -n "$structure_errors" ]]; then
  while IFS= read -r line; do
    echo "error: $line" >&2
  done <<< "$structure_errors"
  fail=1
fi

if [[ $fail -ne 0 ]]; then
  exit 1
fi

echo "structure ok: $CONFIG"

if [[ $OFFLINE -eq 1 ]]; then
  echo "skipping online repo checks (--offline)"
  exit 0
fi

if [[ -z "${GH_TOKEN:-}" ]]; then
  echo "error: GH_TOKEN is not set; use --offline to skip repo checks" >&2
  exit 1
fi

# Every repo named anywhere in the config must exist and be active.
mapfile -t repos < <(jq -r '[.prTools[], .topPullRequests[], .topIssues[], .upgradeDigest[]] | unique[]' "$CONFIG")

for repo in "${repos[@]}"; do
  if ! archived=$(gh repo view "$OWNER/$repo" --json isArchived --jq '.isArchived' 2>/dev/null); then
    echo "error: $OWNER/$repo not found or not accessible" >&2
    fail=1
    continue
  fi
  if [[ "$archived" == "true" ]]; then
    echo "error: $OWNER/$repo is archived" >&2
    fail=1
  else
    echo "ok: $OWNER/$repo"
  fi
done

exit "$fail"
