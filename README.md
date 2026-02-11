# Abeyance (Anti-Gravity Template)

This is the master template for bootstrapping new Anti-Gravity projects. It includes a curated collection of Skills, MCP configurations, and GSD compliancy workflows (Get Shit Done).

## Features

- **Skills Library**: Pre-loaded skills in `.antigravity/skills` ready to be injected into new projects.
- **MCP Configurations**: Master `mcp_config.json` in `.antigravity/mcps` for managing tool connections.
- **GSD Protocol**: Full suite of GSD workflows (`.antigravity/workflows`) automatically installed in new projects.
- **Interactive Setup**: `init.sh` script to interactively select which components to include.

## Usage

### Option 1: Global Workflow (Recommended)
If you have the `use-template` workflow installed globally:
```bash
/use-template
```

### Option 2: Manual Bootstrap
Run the initialization script from any new directory:
```bash
bash "/Users/k4120s/Dev/_K4120S/Antigravity Projects/Origin/init.sh"
```

## Repository Structure

- `.antigravity/`: Contains the source of truth for Skills, MCPs, and Workflows.
- `init.sh`: The logic for scaffolding a new project.

## Contributing
To add new skills or workflows:
1. Add the skill folder to `.antigravity/skills/`.
2. Add the workflow markdown file to `.antigravity/workflows/`.
3. Commit and push changes.
