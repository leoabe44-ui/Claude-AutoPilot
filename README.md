# Claude Autopilot

A Claude Code plugin that lets Claude **prompt itself**. You give it a goal, and it plans, builds, checks its own work and learns, in a loop, until the goal is done.

It combines four ideas:

| Idea | How it works here |
|---|---|
| **Agents** | `planner`, `worker` and `critic` subagents, each with one job |
| **Loops** | A Stop hook sends Claude back to work every time it tries to stop, until the goal is done or it hits the iteration limit |
| **Graphs** | The critic routes each result: `PASS` → next task, `FIX` → back to the worker, `REPLAN` → back to the planner |
| **Self-improving** | After every cycle, a retro writes lessons to `.autopilot/lessons.md`, which every agent reads first |

No API key is needed. It runs inside Claude Code on your normal Claude plan.

---

## Turn it on in a project

Add this to the project's `.claude/settings.json` (create the file if it's missing), then commit it:

```json
{
  "extraKnownMarketplaces": {
    "autopilot": {
      "source": { "source": "github", "repo": "leoabe44-ui/claude-autopilot" }
    }
  },
  "enabledPlugins": {
    "autopilot@autopilot": true
  }
}
```

The next time you open Claude Code in that project, it will offer to install the plugin. This works on your computer and in cloud sessions.

**Or turn it on for every project on your computer, once:** in Claude Code, run

```
/plugin marketplace add leoabe44-ui/claude-autopilot
/plugin install autopilot@autopilot
```

## Use it

| Command | What it does |
|---|---|
| `/autopilot:start "goal" [--max 25]` | Start a run |
| `/autopilot:status` | Show progress, the recent log and the lessons |
| `/autopilot:resume "answer or new instructions"` | Continue after a pause or a question |
| `/autopilot:stop` | Stop. Everything is saved |
| `/autopilot:learn` | Run a retro on recent work, even without a run |

Example:

```
/autopilot:start "Audit the website for broken links, mobile layout bugs and slow pages, and fix the top 5 issues" --max 30
```

## What it writes in your project

```
.autopilot/
  goal.md            the goal and what "done" means (edit it to steer the run)
  plan.md            the task checklist
  lessons.md         this project's memory, read before every task
  log.md             one line per cycle
  global-lessons.md  lessons that apply to any project; copy the good ones into the plugin
  state              run status (not committed)
```

## Safety

- It stops on its own at `max_iterations` (25 by default).
- It won't deploy, delete data, spend money or message people unless you allow that in `goal.md` under `## Allowed`.
- When it needs you, it writes the question in `plan.md` and pauses (`needs_input`).
- Only the session that started the run is looped. Other sessions in the same project behave normally.
- To stop it immediately, run `/autopilot:stop`, or delete `.autopilot/state`.

## Improving the plugin itself

Projects collect general lessons in `.autopilot/global-lessons.md`. Every so often, ask Claude to:
"merge the good lessons from `<project>/.autopilot/global-lessons.md` into the Global lessons section of `plugins/autopilot/skills/autopilot-protocol/SKILL.md` in claude-autopilot". After that, every project benefits.
