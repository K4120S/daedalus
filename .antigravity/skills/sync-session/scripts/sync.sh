#!/usr/bin/env bash
#
# Antigravity Sync Protocol
# ========================
# Read-only repository state check for AI agent context alignment.
# See docs/agent/SYNC_PROTOCOL.md for full documentation.
#
# SAFETY: This script performs NO destructive operations:
# - No merge, rebase, cherry-pick
# - No stash, checkout, reset
# - No file modifications or commits
# - No pushes to remotes
# - Only 'git fetch' is write-like (updates remote tracking refs)

set -euo pipefail

# Output styling
BOLD="\033[1m"
RESET="\033[0m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
CYAN="\033[36m"

# Helper functions
print_header() {
  echo ""
  echo -e "${BOLD}${CYAN}$1${RESET}"
  echo "-------------------------------------------"
}

print_status() {
  local status=$1
  local message=$2
  case $status in
    "pass")
      echo -e "${GREEN}✓${RESET} $message"
      ;;
    "warn")
      echo -e "${YELLOW}⚠${RESET} $message"
      ;;
    "fail")
      echo -e "${RED}✗${RESET} $message"
      ;;
    "info")
      echo -e "${CYAN}→${RESET} $message"
      ;;
  esac
}

# Start report
echo ""
echo "==========================================="
echo -e "${BOLD}ANTIGRAVITY SYNC PROTOCOL REPORT${RESET}"
echo "==========================================="
echo "Timestamp: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# 0. LAST SESSION CONTEXT
print_header "LAST SESSION CONTEXT"

SESSION_FILE=".antigravity/session.json"

if [ -f "$SESSION_FILE" ]; then
  # Simple grep/sed parsing to avoid jq dependency
  LAST_TIMESTAMP=$(grep -o '"timestamp": "[^"]*"' "$SESSION_FILE" | cut -d'"' -f4)
  LAST_SUMMARY=$(grep -o '"summary": "[^"]*"' "$SESSION_FILE" | cut -d'"' -f4)
  LAST_BRANCH=$(grep -o '"branch": "[^"]*"' "$SESSION_FILE" | cut -d'"' -f4)
  LAST_COMMIT=$(grep -o '"commit": "[^"]*"' "$SESSION_FILE" | cut -d'"' -f4)
  
  # New Fields
  LAST_PROD_STATE=$(grep -o '"production_state": "[^"]*"' "$SESSION_FILE" | cut -d'"' -f4)
  LAST_DEV_STATE=$(grep -o '"development_state": "[^"]*"' "$SESSION_FILE" | cut -d'"' -f4)
  
  # Parse open tasks array (simple extraction between [])
  # This extracts the content between [ and ] and removes quotes
  LAST_TASKS=$(grep -o '"open_tasks": \[.*\]' "$SESSION_FILE" | sed 's/"open_tasks": \[//;s/\]//;s/"//g')
  
  echo "Last Saved: $LAST_TIMESTAMP"
  echo "Summary:    $LAST_SUMMARY"
  echo "Context:    $LAST_BRANCH @ ${LAST_COMMIT:0:7}"
  
  echo ""
  echo -e "${BOLD}STATE SNAPSHOT:${RESET}"
  echo "  Production:  ${LAST_PROD_STATE:-Unknown}"
  echo "  Development: ${LAST_DEV_STATE:-Unknown}"
  
  echo ""
  echo -e "${BOLD}OPEN TASKS:${RESET}"
  if [ -n "$LAST_TASKS" ]; then
    # Print comma-separated tasks as list items
    echo "$LAST_TASKS" | awk -F',' '{for(i=1;i<=NF;i++){gsub(/^ *| *$/,"",$i); if($i!="") print "  - " $i}}'
  else
    echo "  (None recorded)"
  fi
  echo ""
  
  # Context Continuity Check
  CURRENT_COMMIT=$(git rev-parse HEAD)
  if [ "$CURRENT_COMMIT" != "$LAST_COMMIT" ]; then
    print_status "warn" "Session discontinuity detected"
    echo "  Current commit ($CURRENT_COMMIT) != Saved commit ($LAST_COMMIT)"
  else
    print_status "pass" "Continuity verified (same commit)"
  fi
else
  print_status "info" "No previous session data found"
fi

# 1. REPOSITORY IDENTITY
print_header "REPOSITORY IDENTITY"

echo "Working Directory: $(pwd)"
echo "Git Root: $(git rev-parse --show-toplevel 2>/dev/null || echo 'NOT A GIT REPO')"

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  print_status "fail" "Not a git repository"
  exit 1
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "DETACHED")
echo "Current Branch: $CURRENT_BRANCH"

echo ""
echo "Remotes:"
git remote -v | sed 's/^/  /'

# 2. WORKING TREE STATUS
print_header "WORKING TREE STATUS"

# Check for in-progress operations
IN_PROGRESS=""
if [ -f .git/MERGE_HEAD ]; then
  IN_PROGRESS="MERGE"
elif [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ]; then
  IN_PROGRESS="REBASE"
elif [ -f .git/CHERRY_PICK_HEAD ]; then
  IN_PROGRESS="CHERRY-PICK"
fi

if [ -n "$IN_PROGRESS" ]; then
  print_status "warn" "In-progress operation detected: $IN_PROGRESS"
else
  echo "In-Progress Operations: None"
fi

# Check working tree cleanliness
if git diff-index --quiet HEAD -- 2>/dev/null && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  print_status "pass" "Working tree is CLEAN"
  TREE_CLEAN=true
else
  print_status "warn" "Working tree has uncommitted changes"
  TREE_CLEAN=false

  # Show modified/staged files
  MODIFIED=$(git diff --name-only | wc -l | tr -d ' ')
  STAGED=$(git diff --cached --name-only | wc -l | tr -d ' ')
  UNTRACKED=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')

  echo ""
  echo "Changes:"
  [ "$MODIFIED" -gt 0 ] && echo "  Modified: $MODIFIED files"
  [ "$STAGED" -gt 0 ] && echo "  Staged: $STAGED files"
  [ "$UNTRACKED" -gt 0 ] && echo "  Untracked: $UNTRACKED files"

  # Show first few files for context
  if [ "$MODIFIED" -gt 0 ] || [ "$STAGED" -gt 0 ]; then
    echo ""
    echo "  Sample files:"
    git status --short | head -n 5 | sed 's/^/    /'
  fi
fi

# 3. UPSTREAM SYNC STATUS
print_header "UPSTREAM SYNC STATUS"

# Fetch from remotes (read-only update of remote tracking refs)
print_status "info" "Fetching latest from remotes..."
if git fetch --all --prune --quiet 2>/dev/null; then
  print_status "pass" "Fetch completed"
else
  print_status "warn" "Fetch failed (may be offline or auth issue)"
fi

# Check upstream tracking
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null || echo "")

if [ -z "$UPSTREAM" ]; then
  print_status "warn" "No upstream tracking branch configured"
else
  echo "Tracking: $UPSTREAM"

  # Calculate ahead/behind
  if COUNTS=$(git rev-list --left-right --count HEAD...$UPSTREAM 2>/dev/null); then
    AHEAD=$(echo "$COUNTS" | awk '{print $1}')
    BEHIND=$(echo "$COUNTS" | awk '{print $2}')

    echo "Position: $AHEAD ahead, $BEHIND behind"

    if [ "$AHEAD" -eq 0 ] && [ "$BEHIND" -eq 0 ]; then
      print_status "pass" "Branch is UP TO DATE with upstream"
    elif [ "$AHEAD" -gt 0 ] && [ "$BEHIND" -eq 0 ]; then
      print_status "info" "Branch is AHEAD (ready to push)"
    elif [ "$AHEAD" -eq 0 ] && [ "$BEHIND" -gt 0 ]; then
      print_status "warn" "Branch is BEHIND (needs pull)"
    else
      print_status "warn" "Branch has DIVERGED (needs reconciliation)"
    fi
  else
    print_status "warn" "Could not calculate ahead/behind counts"
  fi
fi

# 4. RECENT CHANGES CONTEXT
print_header "RECENT CHANGES (last 5 commits)"

git log -5 --oneline --decorate --color=always 2>/dev/null | sed 's/^/  /' || echo "  (no commits)"

# Show files changed in recent commits
echo ""
echo "Files changed in last commit:"
git diff --name-only HEAD~1 HEAD 2>/dev/null | head -n 10 | sed 's/^/  /' || echo "  (no previous commit)"

# 5. QUALITY GATES
print_header "QUALITY GATES"

# Check if this is a docs-only change
DOCS_ONLY=false

# Determine which files to check
if [ "$TREE_CLEAN" = true ]; then
  # Clean tree: check files in last commit
  FILES_TO_CHECK=$(git diff --name-only HEAD~1 HEAD 2>/dev/null || echo "")
else
  # Dirty tree: check uncommitted changes
  FILES_TO_CHECK=$(git diff --name-only 2>/dev/null; git diff --cached --name-only 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null)
fi

# Check if all files are markdown
if [ -n "$FILES_TO_CHECK" ]; then
  if echo "$FILES_TO_CHECK" | grep -v '\.md$' > /dev/null; then
    DOCS_ONLY=false
  else
    DOCS_ONLY=true
    print_status "info" "Docs-only changes detected (gates may be skipped)"
  fi
else
  # No files changed - not docs-only
  DOCS_ONLY=false
fi

# Helper to run a command and capture result
run_gate() {
  local name=$1
  local cmd=$2

  echo ""
  echo -n "$name: "

  if [ "$DOCS_ONLY" = true ] && [ "$name" != "Lint" ]; then
    echo -e "${YELLOW}SKIPPED${RESET} (docs-only)"
    return 0
  fi

  if OUTPUT=$(eval "$cmd" 2>&1); then
    print_status "pass" "PASS"
    return 0
  else
    print_status "fail" "FAIL"
    echo "  First few lines of output:"
    echo "$OUTPUT" | head -n 10 | sed 's/^/    /'
    return 1
  fi
}

GATES_PASSED=true

# Check if npm is available and package.json exists
if [ ! -f package.json ]; then
  print_status "warn" "No package.json found (skipping quality gates)"
elif ! command -v npm &> /dev/null; then
  print_status "warn" "npm not available (skipping quality gates)"
else
  # Lint
  if npm run lint --silent 2>&1 | grep -q "Missing script"; then
    print_status "warn" "Lint: SKIPPED (no lint script)"
  else
    run_gate "Lint" "npm run lint" || GATES_PASSED=false
  fi

  # Test
  if npm run test --silent 2>&1 | grep -q "Missing script"; then
    print_status "warn" "Test: SKIPPED (no test script)"
  else
    run_gate "Test" "npm test" || GATES_PASSED=false
  fi

  # Build
  if npm run build --silent 2>&1 | grep -q "Missing script"; then
    print_status "warn" "Build: SKIPPED (no build script)"
  else
    run_gate "Build" "npm run build" || GATES_PASSED=false
  fi
fi

# 6. SUMMARY
print_header "SUMMARY"

ISSUES=()
RECOMMENDATIONS=()

# Collect issues
if [ -n "$IN_PROGRESS" ]; then
  ISSUES+=("In-progress $IN_PROGRESS operation")
  RECOMMENDATIONS+=("Resolve or abort the $IN_PROGRESS before starting new work")
fi

if [ "$TREE_CLEAN" = false ]; then
  ISSUES+=("Uncommitted changes in working tree")
  RECOMMENDATIONS+=("Review changes and commit or stash before proceeding")
fi

if [ -n "$UPSTREAM" ]; then
  if [ "$BEHIND" -gt 0 ]; then
    ISSUES+=("Branch is $BEHIND commits behind upstream")
    RECOMMENDATIONS+=("Pull latest changes with: git pull")
  fi

  if [ "$AHEAD" -gt 0 ] && [ "$BEHIND" -gt 0 ]; then
    ISSUES+=("Branch has diverged from upstream")
    RECOMMENDATIONS+=("Reconcile divergence (pull + merge/rebase) before continuing")
  fi
fi

if [ "$GATES_PASSED" = false ]; then
  ISSUES+=("One or more quality gates failed")
  RECOMMENDATIONS+=("Fix failing gates before starting new work")
fi

# Print issues or all-clear
if [ ${#ISSUES[@]} -eq 0 ]; then
  print_status "pass" "Repository state is healthy"
  print_status "pass" "All quality gates passed"
  print_status "pass" "Ready for development"
else
  echo "Issues detected:"
  for issue in "${ISSUES[@]}"; do
    print_status "warn" "$issue"
  done

  if [ ${#RECOMMENDATIONS[@]} -gt 0 ]; then
    echo ""
    echo "Recommended actions:"
    for rec in "${RECOMMENDATIONS[@]}"; do
      print_status "info" "$rec"
    done
  fi
fi

echo ""
echo "==========================================="
echo ""

# Exit with appropriate code
if [ ${#ISSUES[@]} -eq 0 ]; then
  exit 0
else
  exit 1
fi
