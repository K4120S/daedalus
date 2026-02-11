---
name: save-session
description: "Final operation in every coding session. Ensures clean state by committing and pushing all changes, then persists session context to .antigravity/session.json. MUST be called before ending a session."
---

# Save Session (Session END)

**Purpose**: This is the **FINAL operation** in every coding session. It ensures the repository is in a clean, stable state before ending work.

**Session Bookend**: This skill pairs with `sync-session` (session START) to maintain continuity between agent sessions.

## Critical Requirements

### 1. Clean Git State (MANDATORY)
Before calling this skill, you MUST:
- ✅ Commit all changes
- ✅ Push to remote repository
- ✅ Ensure working directory is clean

**Rule**: A saved session state MUST NEVER have uncommitted changes or unpushed commits.

### 2. Stable State (MANDATORY)
- ✅ All work complete or cleanly paused
- ✅ No lint errors (unless documented as known issues)
- ✅ No broken features
- ✅ No half-finished refactorings

### 3. Open Tasks (Optional)
- Log any remaining work for next session
- Link to relevant devlog entries
- Note any blockers or dependencies

## Usage

```bash
# ONLY call after committing and pushing all changes
bash .agent/skills/save-session/scripts/save.sh "Brief summary of work completed"
```

## Pre-Save Checklist

Run these commands before save-session:

```bash
# 1. Check status
git status

# 2. Commit all changes
git add .
git commit -m "your commit message"

# 3. Push to remote
git push origin main

# 4. Verify clean state
git status  # Should show "nothing to commit, working tree clean"

# 5. NOW save session
bash .agent/skills/save-session/scripts/save.sh "session summary"
```

## Functionality

1. **Validates Clean State**: Checks for uncommitted changes (warns if dirty)
2. **Captures Git State**: Branch, commit hash, sync status with remote
3. **Enforces Documentation Consistency**: Verifies docs accompany code changes
4. **Captures Session Context**:
   - Production State (e.g., "Live - Stable")
   - Development State (e.g., "Complete - all tests passing")
   - Open Tasks (for next session)
5. **Generates JSON**: Writes all metadata to `.antigravity/session.json`

## Requirements

- `git` must be installed and initialized
- Must be run from repository root
- **All changes must be committed and pushed before calling**

## Typical Session END Workflow

```bash
# 1. Complete your work
# 2. Run final checks
npm run lint
npm run build  # if applicable

# 3. Commit and push
git add .
git commit -m "feat: completed X feature"
git push origin main

# 4. Save session (this skill)
antigravity:save "Completed X feature, verified and deployed"

# 5. End session
```

## Anti-Patterns (DO NOT DO THIS)

❌ Saving with uncommitted changes  
❌ Saving with unpushed commits  
❌ Saving with broken tests  
❌ Saving mid-refactoring  
❌ Saving without summary

**Remember**: This is the last thing you do in a session. Leave the repo clean for the next session.
