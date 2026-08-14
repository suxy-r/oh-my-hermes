#!/usr/bin/env bash
# Repository-level checks that do not require an installed Hermes runtime.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

for script in "$REPO_DIR"/install.sh "$SCRIPT_DIR"/*.sh; do
  bash -n "$script"
done

bash "$SCRIPT_DIR/validate-skills.sh"

if rg -n '^(<<<<<<<|=======|>>>>>>>)' "$REPO_DIR" \
  --glob '!banner.png' --glob '!scripts/repo-test.sh'; then
  echo "Unresolved merge marker found" >&2
  exit 1
fi

mkdir -p "$TMP_DIR/profile"
printf '# Custom profile\n\nKeep this user section.\n' > "$TMP_DIR/profile/SOUL.md"
bash "$SCRIPT_DIR/update-profile-soul.sh" \
  "$TMP_DIR/profile" "$REPO_DIR/agents/cto.md" cto

grep -Fq 'Keep this user section.' "$TMP_DIR/profile/SOUL.md"
grep -Fq '<!-- oh-my-hermes:role:cto:start -->' "$TMP_DIR/profile/SOUL.md"
grep -Fq 'This `SOUL.md` block is the authoritative role' "$TMP_DIR/profile/SOUL.md"
grep -Fq '# CTO Agent' "$TMP_DIR/profile/SOUL.md"

FIRST_HASH="$(cksum "$TMP_DIR/profile/SOUL.md" | awk '{print $1 ":" $2}')"
bash "$SCRIPT_DIR/update-profile-soul.sh" \
  "$TMP_DIR/profile" "$REPO_DIR/agents/cto.md" cto
SECOND_HASH="$(cksum "$TMP_DIR/profile/SOUL.md" | awk '{print $1 ":" $2}')"

if [ "$FIRST_HASH" != "$SECOND_HASH" ]; then
  echo "SOUL managed-block update is not idempotent" >&2
  exit 1
fi

if [ "$(grep -Fc '<!-- oh-my-hermes:role:cto:start -->' "$TMP_DIR/profile/SOUL.md")" -ne 1 ]; then
  echo "SOUL contains duplicate managed blocks" >&2
  exit 1
fi

echo "Repository checks passed."
