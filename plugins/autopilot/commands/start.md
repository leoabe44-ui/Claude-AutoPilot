---
description: Start an Autopilot run. Claude plans, builds, checks and learns in a loop until the goal is done.
argument-hint: "<goal>" [--max N]
---

Start an Autopilot run in this project with this goal:

$ARGUMENTS

Do this:

1. If `.autopilot/state` exists with `status=running`, tell the user a run is already active and stop. They can use `/autopilot:resume` or `/autopilot:stop`.
2. Create `.autopilot/` (keep any existing `lessons.md`, because it is this project's memory):
   - `goal.md`: the goal above, then a `## Done means` section with 2–5 concrete, checkable criteria you infer. Add a `## Allowed` section that says: `Deploying, deleting data, spending money and messaging people: NOT allowed unless the user adds it here.`
   - `lessons.md`: create it if missing, with the heading `# Lessons (read before every task)`.
   - `log.md`: create it if missing.
   - `state`, exactly these lines (use the `--max` value if given, otherwise 25):
     ```
     status=running
     iteration=0
     max_iterations=25
     session=
     ```
3. If this is a git repo, make sure `.gitignore` contains `.autopilot/state` and `.autopilot/state.tmp`.
4. Show the user the goal and the "Done means" criteria in 3–6 lines. Then start right away: follow the **autopilot-protocol** skill, beginning with the planner.
