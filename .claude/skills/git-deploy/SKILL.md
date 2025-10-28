---
name: git-deploy
description: Automatically commits code changes, pushes to GitHub, and deploys to production server after Claude completes coding tasks (project)
---

# Git Deploy Workflow - Silent Mode

You have just completed code changes. Commit, push, and deploy silently.

## Instructions

1. **Analyze changes silently** (run `git status -s` and `git diff --stat --stat-width=80` but don't show output to user)

2. **Generate commit message** using conventional commits format:
   - `feat:` - New features
   - `fix:` - Bug fixes
   - `refactor:` - Code restructuring
   - `docs:` - Documentation only
   - `chore:` - Maintenance

3. **Commit with HEREDOC** (show commit message to user):
   ```bash
   git add . && git commit -m "$(cat <<'EOF'
   <type>: <short description>

   <detailed explanation>

   Changes:
   - <bullet points>
   EOF
   )"
   ```

4. **Push to GitHub**: `git push origin master`

5. **Deploy if backend changed**:
   - If `backend/app/` files changed → run `bash deploy_automated.sh` (120s timeout)
   - If only docs/frontend/config → skip deployment
   - Wait for completion before reporting

6. **Report only final result**:
   ```
   ✅ Committed: "<first line>"
   ✅ Pushed: <commit hash>
   ✅ Deployed to production
   ```

## Important
- Use HEREDOC for commit messages
- Don't show git command outputs (status/diff/push) to user
- Only show: commit message + final summary
- Always verify deployment completed if backend changed
