# AGENTS.md — House Rules for This Fork

## Purpose
This file tells automation (Codex, etc.) how to behave in **this fork**. Keep it small, local, and boring.

## Don’ts
- Do **not** enable or run GitHub Actions in this fork.
- Do **not** touch or overwrite my local files:
  - `requirements.txt`
  - `models/vae_approx/*.safetensors`
- Do **not** pull external repos, run submodules, or scaffold CI.
- Do **not** open PRs to `comfyanonymous/ComfyUI`. Pull only.

## Upstream Sync Flow (Always)
1. `git fetch upstream`
2. `git checkout -B sync-upstream master`
3. `git merge upstream/master`
4. Restore protected files AND re-apply all personal changes from `origin/master` (personal precedence):
   - Protected paths:
     - `git checkout origin/master -- requirements.txt`
     - `git checkout origin/master -- models/vae_approx || true`
   - Personal precedence (all files changed on `origin/master` since the merge-base):
     - Determine base: ``BASE=$(git merge-base origin/master upstream/master)``
     - For each file in ``git diff --name-only "$BASE"..origin/master`` run: ``git checkout origin/master -- <file>``
   - `git commit --no-edit || true`
5. Sanity check: `git --no-pager diff --stat master..HEAD`
6. Keep the staging branch `sync-upstream` for future syncs (do not delete). Optionally publish it: `git push -u origin sync-upstream`
7. Promote: `git switch master && git merge --ff-only sync-upstream && git push origin master`

## Fork Update Process (Simplified)

Whenever I say “update fork,” follow these exact steps:

1. Fetch upstream:
   git fetch upstream

2. Create or reset the staging branch:
   git checkout -B sync-upstream master

3. Merge upstream changes:
   git merge upstream/master

4. Restore protected files AND re-apply all personal changes from origin/master:
   # protected
   git checkout origin/master -- requirements.txt
   git checkout origin/master -- models/vae_approx || true
   # personal precedence (since merge-base)
   BASE=$(git merge-base origin/master upstream/master)
   for f in $(git diff --name-only "$BASE"..origin/master); do git checkout origin/master -- "$f"; done
   git commit --no-edit || true

5. Fast-forward master and push:
   git switch master
   git merge --ff-only sync-upstream
   git push origin master

6. Leave the staging branch in place for next sync (do not delete).

---

This way, every sync is the same: safe branch first, protect local files, fast-forward master, push. No PRs, no guesswork.

## Preferred: One-Command Sync
- Use the helper script which enforces protected paths and personal precedence automatically:
  - `bash scripts/update_fork.sh`
  - It fetches upstream, merges into `sync-upstream`, restores protected paths, re-applies all personal changes from `origin/master` (since merge-base), then fast-forwards `master` and pushes to `origin`.
  - It never pushes to `upstream` and leaves `sync-upstream` intact.

## Local Run
- Create venv, install: `python -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt`
- Launch: `python main.py --listen --port 8188`

## Editing Notes
- Python 3.9+, type hints for new code, no prints in hot paths.
- Prefer small, clear commits with imperative messages.

## Codex Rules
- Treat the above as mandatory. If a merge conflicts with protected paths, prefer **ours**.
- Ask before changing dependency files or model folders. Otherwise proceed with the sync flow.
 - Personal precedence (mandatory): after any upstream merge, re-apply all changes made on `origin/master` since the merge-base so that local commits always take precedence over upstream.
 - Never push to `upstream/*` under any circumstances unless explicitly asked to prepare an upstream PR.
 - Do not delete `sync-upstream`; it is the permanent staging branch for sync.
