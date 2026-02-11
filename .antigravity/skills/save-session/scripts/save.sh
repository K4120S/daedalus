#!/usr/bin/env bash
#
# Antigravity Session Save
# ========================
# Captures current repository state and session context for the next session.
# See docs/agent/SESSION_PROTOCOL.md
#

set -euo pipefail

# Output styling
BOLD="\033[1m"
RESET="\033[0m"
GREEN="\033[32m"
CYAN="\033[36m"
YELLOW="\033[33m"

SESSION_DIR=".antigravity"
SESSION_FILE="$SESSION_DIR/session.json"

# Ensure session directory exists
mkdir -p "$SESSION_DIR"

# Get user summary argument (optional)
SUMMARY="${1:-No summary provided}"

echo -e "${BOLD}${CYAN}Saving Antigravity Session...${RESET}"

# Interactive Inputs for Strict State Tracking or use defaults if non-interactive
if [ -t 0 ]; then
    echo -e "${YELLOW}Enter Production State (e.g., 'Live - Stable', 'Staging - Broken'):${RESET}"
    read -r PROD_STATE
    
    echo -e "${YELLOW}Enter Development State (e.g., 'Feature Complete', 'Work in Progress'):${RESET}"
    read -r DEV_STATE
    
    echo -e "${YELLOW}Enter Open Tasks (comma-separated, e.g., 'Fix bug, Update docs'):${RESET}"
    read -r TASKS_INPUT
else
    PROD_STATE="Unknown (Non-interactive save)"
    DEV_STATE="Unknown (Non-interactive save)"
    TASKS_INPUT="Check task.md"
fi

# Format tasks as JSON array
# Simple comma-split and quote wrapping
TASKS_JSON=$(echo "$TASKS_INPUT" | awk -F',' '{for(i=1;i<=NF;i++){gsub(/^ *| *$/,"",$i); printf "\"%s\"%s", $i, (i==NF?"":", ")}}' | sed 's/^/[/' | sed 's/$/]/')

# Capture Git State
BRANCH=$(git rev-parse --abbrev-ref HEAD)
COMMIT=$(git rev-parse HEAD)
MODIFIED=$(git diff --name-only | wc -l | tr -d ' ')
STAGED=$(git diff --cached --name-only | wc -l | tr -d ' ')
UNTRACKED=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')

# Determine Dirty State
if [ "$MODIFIED" -gt 0 ] || [ "$STAGED" -gt 0 ] || [ "$UNTRACKED" -gt 0 ]; then
  IS_DIRTY=true
else
  IS_DIRTY=false
fi

# STRICT PROTOCOL: Abort if dirty
if [ "$IS_DIRTY" = true ]; then
  echo -e "${RED}${BOLD}ABORT: Cannot save with uncommitted changes.${RESET}"
  echo -e "${YELLOW}  - Modified: $MODIFIED${RESET}"
  echo -e "${YELLOW}  - Staged:   $STAGED${RESET}"
  echo -e "${YELLOW}  - Untracked: $UNTRACKED${RESET}"
  echo ""
  echo -e "${CYAN}Please commit or stash your changes first:${RESET}"
  echo "  git add -A && git commit -m \"your message\""
  echo ""
  exit 1
fi

# Documentation Consistency Check
# Check if any files in src/ are modified/staged (Safe grep handling)
ALL_CHANGED=$(git diff --name-only HEAD)
SRC_CHANGED=$(echo "$ALL_CHANGED" | grep -c "^src/" || true)
DOCS_CHANGED=$(echo "$ALL_CHANGED" | grep -c "^docs/" || true)

DOCS_VERIFIED="true"

if [ "$SRC_CHANGED" -gt 0 ] && [ "$DOCS_CHANGED" -eq 0 ]; then
    echo -e "${RED}${BOLD}STOP! Source code changes detected without documentation updates.${RESET}"
    echo -e "${YELLOW}  - $SRC_CHANGED source files modified${RESET}"
    echo -e "${YELLOW}  - 0 documentation files modified${RESET}"
    echo ""
    
    if [ -t 0 ]; then
        echo -e "${YELLOW}Have you verified that NO documentation updates are required? (y/n)${RESET}"
        read -r CONFIRM_DOCS
        if [ "$CONFIRM_DOCS" != "y" ]; then
            echo -e "${RED}Save aborted. Please update documentation using 'antigravity task' or edit manually.${RESET}"
            exit 1
        fi
        DOCS_VERIFIED="verified_despite_warning"
    else
        DOCS_VERIFIED="false_warning_ignored_noninteractive"
    fi
fi

# Create JSON payload
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat > "$SESSION_FILE" <<EOF
{
  "timestamp": "$timestamp",
  "summary": "$(echo "$SUMMARY" | sed 's/"/\\"/g')",
  "production_state": "$(echo "$PROD_STATE" | sed 's/"/\\"/g')",
  "development_state": "$(echo "$DEV_STATE" | sed 's/"/\\"/g')",
  "docs_verified": "$DOCS_VERIFIED",
  "open_tasks": $TASKS_JSON,
  "git": {
    "branch": "$BRANCH",
    "commit": "$COMMIT",
    "is_dirty": $IS_DIRTY,
    "stats": {
      "modified": $MODIFIED,
      "staged": $STAGED,
      "untracked": $UNTRACKED
    }
  }
}
EOF

echo -e "${GREEN}✓ Session saved to $SESSION_FILE${RESET}"
echo "  Timestamp:  $timestamp"
echo "  Summary:    $SUMMARY"
echo "  Prod State: $PROD_STATE"
echo "  Dev State:  $DEV_STATE"
echo "  Tasks:      $TASKS_INPUT"
if [ "$IS_DIRTY" = true ]; then
  echo -e "  ${YELLOW}⚠ Saved with uncommitted changes${RESET}"
fi
