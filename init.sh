#!/bin/bash

# Anti-Gravity Project Initializer
# This script scaffolds a new project from the template by selectively including skills and MCPs.

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ANTI-GRAVITY PROJECT INITIALIZER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Detect if we are in a new project or an existing one
if [ ! -d ".agent" ]; then
    echo "Creating .agent directory..."
    mkdir -p .agent/skills .agent/workflows
fi

# 1.5 Setup GSD Protocol (Workflows)
echo "Setting up GSD Protocol..."
WORKFLOWS_DIR="$TEMPLATE_DIR/.antigravity/workflows"
if [ -d "$WORKFLOWS_DIR" ]; then
    cp -R "$WORKFLOWS_DIR/"* ".agent/workflows/"
    echo "GSD Workflows installed."
else
    echo "Warning: GSD Workflows not found in template."
fi

# 2. Select Skills
echo "--- Select Skills to include ---"
SKILLS_DIR="$TEMPLATE_DIR/.antigravity/skills"
AVAILABLE_SKILLS=$(ls "$SKILLS_DIR")

for skill in $AVAILABLE_SKILLS; do
    read -p "Include skill '$skill'? (y/n): " choice
    if [ "$choice" == "y" ]; then
        echo "Adding skill: $skill"
        cp -R "$SKILLS_DIR/$skill" ".agent/skills/"
    fi
done

# 3. Select MCP Connections
echo ""
echo "--- Select MCP Connections to include ---"
MASTER_MCP_CONFIG="$TEMPLATE_DIR/.antigravity/mcps/master_mcp_config.json"
TEMP_CONFIG=".agent/mcp_config.json"

if [ -f "$MASTER_MCP_CONFIG" ]; then
    # Create an empty or base mcp_config.json if it doesn't exist
    if [ ! -f "$TEMP_CONFIG" ] || [ ! -s "$TEMP_CONFIG" ]; then
        echo '{"mcpServers": {}}' > "$TEMP_CONFIG"
    fi

    # Extract server names from master config
    if command -v jq >/dev/null 2>&1; then
        SERVERS=$(jq -r '.mcpServers | keys[]' "$MASTER_MCP_CONFIG")
        for server in $SERVERS; do
            read -p "Enable MCP server '$server'? (y/n): " choice
            if [ "$choice" == "y" ]; then
                echo "Adding MCP server: $server"
                # Extract and merge the specific server config
                SERVER_CONFIG=$(jq -c ".mcpServers.\"$server\"" "$MASTER_MCP_CONFIG")
                jq ".mcpServers.\"$server\" = $SERVER_CONFIG" "$TEMP_CONFIG" > "$TEMP_CONFIG.tmp" && mv "$TEMP_CONFIG.tmp" "$TEMP_CONFIG"
            fi
        done
    else
        echo "Warning: 'jq' is not installed. Manual MCP configuration required for now."
    fi
else
    echo "Master MCP config not found."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  INITIALIZATION COMPLETE ✓"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
