---
name: sync-session
description: "First operation in every coding session. Loads previous session state, checks local/remote repo sync, reviews latest devlog, reports open tasks, and builds comprehensive status report. MUST be called when starting a session."
---

# Sync Session (Session START)

**Purpose**: This is the **FIRST operation** in every coding session. It restores context and provides a comprehensive status report.

**Session Bookend**: This skill pairs with `save-session` (session END) to maintain continuity between agent sessions.

## Usage

```bash
# ALWAYS call this when starting a new session
bash .agent/skills/sync-session/scripts/sync.sh
```

## Comprehensive Checks

### 1. Session State Recovery
- ✅ Loads `.antigravity/session.json` (last saved state)
- ✅ Displays previous session summary
- ✅ Shows production and development state
- ✅ Lists open tasks from last session

### 2. Git Repository Sync
- ✅ Checks current branch and commit
- ✅ Compares with saved session commit (detects external changes)
- ✅ Compares local with remote (ahead/behind status)
- ✅ Warns if uncommitted changes exist
- ✅ Reports if repo state differs from saved session

### 3. Latest Devlog Review
- ✅ Finds most recent devlog entry in `docs/devlogs/`
- ✅ Displays filename and summary
- ✅ Correlates with saved session timestamp

### 4. Health Checks
- ✅ Verifies session file exists and is valid JSON
- ✅ Checks if working directory is clean
- ✅ Confirms remote tracking is configured

## Output Report Format

```
==============================================
Antigravity Session Sync
==============================================

LAST SESSION:
  Timestamp:    2026-01-16T10:35:00Z
  Summary:      inquiry-gate fully verified
  Prod State:   Live - Stable
  Dev State:    Complete - verified and pushed

GIT STATUS:
  Current Branch:    main
  Current Commit:    8862e8e
  Saved Commit:      8862e8e  ✓ Match
  Remote Status:     Up to date with origin/main
  Working Tree:      Clean

LATEST DEVLOG:
  File:    docs/devlogs/2026-01-15__scroll-fix.md
  Created: 2026-01-15T17:17:52Z

OPEN TASKS:
  - None - all work complete

STATUS: ✓ Repository in sync, ready to continue
==============================================
```

## Continuity Warnings

The sync will warn if:
- ⚠️ Current commit differs from saved commit (external changes detected)
- ⚠️ Local branch is ahead/behind remote
- ⚠️ Working directory has uncommitted changes
- ⚠️ Session file is missing or invalid

## Typical Session START Workflow

```bash
# 1. Start terminal in repo
cd /path/to/repo

# 2. Sync session (this skill)
antigravity:sync

# 3. Review the report
# 4. Address any warnings
# 5. Continue work from open tasks
```

## Requirements

- `.antigravity/session.json` must exist (created by save-session)
- `git` must be installed and initialized
- Must be run from repository root
- Remote tracking branch must be configured

## What This Enables

**Context Restoration**: Know exactly what was done last session  
**Continuity Checks**: Detect if repo changed since last session  
**Task Tracking**: Pick up where you left off  
**Health Verification**: Ensure repo is in good state before starting work

**Remember**: This is the first thing you do in a session. It sets the stage for productive work.

## Feature Naming

When discussing features in session context or open tasks, use canonical names from the **[Naming Registry](../../docs/NAMING_REGISTRY.md)**:
- Reference features by their **Generic Name** (e.g., "Landing Page Agent")
- Include **Working Title** if clarification needed (e.g., "Landing Page Agent (Agent Zero)")
- Maintain consistency with devlog entries and documentation
