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
4. Ensure protected paths are unchanged:
   - `git checkout origin/master -- requirements.txt`
   - `git checkout origin/master -- models/vae_approx || true`
5. Sanity check: `git --no-pager diff --stat master..HEAD`
6. Publish: `git push -u origin sync-upstream`
7. Promote: `git switch master && git merge --ff-only sync-upstream && git push origin master`

## Local Run
- Create venv, install: `python -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt`
- Launch: `python main.py --listen --port 8188`

## Editing Notes
- Python 3.9+, type hints for new code, no prints in hot paths.
- Prefer small, clear commits with imperative messages.

## Codex Rules
- Treat the above as mandatory. If a merge conflicts with protected paths, prefer **ours**.
- Ask before changing dependency files or model folders. Otherwise proceed with the sync flow.
