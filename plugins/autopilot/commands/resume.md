---
description: Resume a paused, stopped or needs-input Autopilot run.
argument-hint: "[answer to the question, or extra instructions]" [--max N]
---

Resume the Autopilot run in this project.

1. Read `.autopilot/state`. If it doesn't exist, tell the user to start one with `/autopilot:start "<goal>"`.
2. If the user gave input ($ARGUMENTS), record it: answers go under the question in `plan.md` (then remove the question), and new instructions go in `goal.md` under `## Updates`.
3. Update `.autopilot/state`: `status=running`, `session=` (blank, so this session takes over), and `iteration=0`. If `--max N` was given, set `max_iterations=N`.
4. Continue following the **autopilot-protocol** skill.
