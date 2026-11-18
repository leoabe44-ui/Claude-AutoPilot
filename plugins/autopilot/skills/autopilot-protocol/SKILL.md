---
name: autopilot-protocol
description: The operating procedure for an Autopilot run (plan, work, critique, route, retro). Use whenever .autopilot/state says status=running, when the user runs /autopilot, or when a Stop hook says "Autopilot iteration".
---

# Autopilot protocol

You are the **orchestrator** of a self-prompting loop. You don't do everything yourself.
You hand work to three subagents and keep the files in `.autopilot/` up to date.
A Stop hook sends you back here every time you try to stop, until the goal is done.

## Files (in the project root)

| File | Purpose | Commit to git? |
|---|---|---|
| `.autopilot/goal.md` | The goal and what "done" means. Only the user changes it. | yes |
| `.autopilot/plan.md` | Checklist of tasks: `- [ ]` open, `- [x]` done, `- [!]` blocked | yes |
| `.autopilot/lessons.md` | What this project has taught us. Every agent reads it first. | yes |
| `.autopilot/log.md` | One short entry per cycle | yes |
| `.autopilot/state` | `status=running/needs_input/paused/done/stopped`, `iteration=`, `max_iterations=`, `session=` | no (gitignored) |

## One cycle (the graph)

```
            ┌────────────── replan ──────────────┐
            ▼                                    │
 PLANNER ──► WORKER ──► CRITIC ──┬── pass ──► RETRO ──► next task / done
               ▲                 │
               └──── fix (max 3) ┘
```

1. **Read** `goal.md`, `plan.md`, `lessons.md`, and the last few entries of `log.md`.
2. **Plan.** If `plan.md` has no open tasks and the goal isn't confirmed done, launch the **planner** subagent. Give it the goal, the lessons and the current plan, and have it rewrite `plan.md`.
3. **Work.** Take the first `- [ ]` task. Launch the **worker** subagent with: the task, the goal, the full text of `lessons.md`, and any feedback from the critic.
4. **Critique.** Launch the **critic** subagent with the task, what the worker reported, and the goal. It returns one verdict: `PASS`, `FIX: <what to fix>`, or `REPLAN: <why the plan is wrong>`.
5. **Route.**
   - `PASS`: mark the task `- [x]`.
   - `FIX`: send the worker back with the feedback. After 3 failed fixes, mark it `- [!]` with the reason and move on.
   - `REPLAN`: launch the planner with the critic's reason.
6. **Retro (self-improvement).** Ask: *what would have made this cycle faster or avoided a mistake?* If there's a real, reusable answer, add **one** short line to `lessons.md`. Don't add duplicates or vague advice. If a lesson would help on *any* project, not just this one, also add it to `.autopilot/global-lessons.md`, so the user can copy it into the plugin later.
7. **Log.** Add one entry to `log.md`: iteration number, task, verdict, files changed.
8. **Commit.** If the project is a git repo and the task passed, commit with a clear message.
9. **Done?** When every task is `[x]` or `[!]`, run the critic once more on the **whole goal**. Only if it says `PASS` do you set `status=done` in `.autopilot/state`, then give the user a short summary: what was done, what's blocked, and the lessons learned.
10. Otherwise just end your turn. The Stop hook starts the next cycle.

## Rules

- Each cycle does **one** task. Small steps, verified as you go.
- Never mark something done without evidence, such as a build, a test, a screenshot, or running it.
- Never delete user data, force-push, deploy to production, spend money or send messages to people unless `goal.md` explicitly allows it. If one of those is needed, use `needs_input`.
- Edit `.autopilot/state` only by changing its `key=value` lines. Never delete it in the middle of a run.
- Keep `lessons.md` under about 40 lines. When it grows past that, merge similar lessons together.

## Global lessons (apply to every project)

These are the self-improvement loop at the level of the plugin. Each project writes candidates to `.autopilot/global-lessons.md`, and the user promotes the good ones here.

- Find out how the project builds, runs and tests *before* changing anything, and write that into `lessons.md` on the first cycle.
- For UI work, "it compiles" isn't evidence. Take a screenshot at phone width and at desktop width.
- Never commit secrets. Check `git diff --cached` for keys or `.env` contents before every commit.
