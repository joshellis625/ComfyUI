#!/usr/bin/env bash
set -euo pipefail

# Update fork from upstream while ensuring:
# - Protected paths are restored from origin/master
# - ALL personal changes on origin/master (since its merge-base with upstream/master)
#   take precedence over upstream changes
# - Never pushes to upstream

echo "[update_fork] Ensuring upstream push is disabled"
git remote set-url --push upstream no_push || true

echo "[update_fork] Fetching upstream"
git fetch upstream --prune

echo "[update_fork] Creating/resetting staging branch sync-upstream from master"
git checkout -B sync-upstream master

echo "[update_fork] Merging upstream/master into sync-upstream"
git merge upstream/master --no-edit || true

echo "[update_fork] Restoring protected paths from origin/master"
git checkout origin/master -- requirements.txt || true
git checkout origin/master -- models/vae_approx || true

echo "[update_fork] Restoring all personal changes from origin/master (precedence)"
BASE=$(git merge-base origin/master upstream/master)
if [ -n "${BASE}" ]; then
  # Files changed on origin/master since merge-base
  PERSONAL_FILES=$(git diff --name-only "$BASE"..origin/master || true)
  if [ -n "${PERSONAL_FILES}" ]; then
    # Exclude protected paths already handled
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      case "$f" in
        requirements.txt|models/vae_approx/*)
          continue
          ;;
      esac
      echo "  - preferring origin/master version of: $f"
      git checkout origin/master -- "$f" || true
    done <<EOF
${PERSONAL_FILES}
EOF
  fi
fi

# Commit merge + restorations if needed
if ! git diff --quiet || ! git diff --cached --quiet; then
  git commit --no-edit -m "sync-upstream: prefer origin/master for protected and personal changes"
fi

echo "[update_fork] Fast-forwarding master to sync-upstream and pushing to origin"
git switch master
git merge --ff-only sync-upstream
git push origin master

echo "[update_fork] Done. Leaving sync-upstream branch in place for future syncs."

