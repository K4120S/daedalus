# Project Brief: Basketball Playbook & Learning App

## Context
- **Team Name**: Minotaurs
- **Theme**: The Labyrinth (The Playbook is the maze the opponents cannot escape).

## Vision (The Soul)
A collaborative platform for the **Minotaurs** basketball team to design, view, and learn plays.
- **For Coaches**: A powerful "Playbook Designer" (The Architect/Daedalus) to sketch plays.
- **For Players**: A learning app to view plays in motion.
- **Core Value**: Transforming static diagrams into dynamic, understandable lessons.

## Primitives (The Body)
- **`Play`**: A specific strategy (e.g., "Motion Offense", "2-3 Zone").
- **`Sequence`**: The timeline of the play, consisting of multiple frames/steps.
- **`Actor`**: Entities on the court (Players 1-5, Ball). Tracking (x,y) coordinates over time.
- **`Annotation`**: Explanatory text or graphical overlays (arrows, zones) tied to specific moments.

## Technical Stack
- **Frontend**: React (Vite)
- **Visualization**: `react-konva` (HTML5 Canvas) for high-performance animation and dragging.
- **Backend/Auth**: Supabase (Postgres) to handle Team/Player roles and JSON storage for plays.
- **Styling**: TailwindCSS (Standard Anti-Gravity).

## Constraints
- Mobile-responsive for players viewing on phones.
- Desktop-optimized for coaches designing plays.
