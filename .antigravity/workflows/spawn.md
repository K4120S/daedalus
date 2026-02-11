---
name: spawn
description: Ideate, define, and spawn a new Anti-Gravity project
allowed-tools:
  - Read
  - Bash
  - Write
  - Task
  - AskUserQuestion
---

<objective>
Guide the creation of a new Anti-Gravity project from the Origin template.
This workflow focuses on the "Soul" and "Body" of the new project before it is physically created.
Process: Ideation -> Definition -> Research (Optional) -> Brief -> Generation.
</objective>

<process>

## Phase 1: The Soul (Ideation)
**Establish the core concept.**

Ask user: "What is the high-level concept? What is the 'Soul' of this new project?"
- Explore the "Why".
- Identify the primary user or agent.
- Visualise the end state.

## Phase 2: The Body (Primitives & Definition)
**Define the technical reality.**

Ask user: "What are the core primitives and technical dependencies?"
- Primitives: What are the atomic units of data/logic?
- Dependencies: What external systems or libraries are critical?
- Stack: Any specific language or framework requirements differing from standard?

## Phase 3: Research (Optional)
**Validate the approach.**

Use AskUserQuestion: "Do we need to research the dependencies or primitives?"
- Options: "Yes", "No (Skip)".

If "Yes":
- Spawn `gsd-project-researcher` to investigate the identified primitives/dependencies.
- Synthesize findings into a temporary definition document.

## Phase 4: The Brief
**Compile the DNA.**

Create a temporary file `BRIEF.md` with:
- **Project Name**: (Ask user if not defined)
- **Vision**: The "Soul".
- **Primitives**: The core data structures/logic.
- **Stack/Dependencies**: Confirmed technical requirements.
- **Context**: Any research findings.

Confirm with user that `BRIEF.md` allows us to proceed to birth.

## Phase 5: Conception (Generation)
**Birth the project.**

1.  Ask user for the `Project Name` (slug format preferred).
2.  Execute the spawner script:
    ```bash
    bash spawn.sh "{project_name}" "BRIEF.md"
    ```
3.  If successful, the script will output the location of the new project.

## Phase 6: Handoff
Notify user: "Project '{project_name}' has been spawned at `../{project_name}`. It is initialized with GSD and connected to GitHub."

</process>
