---
description: Run a retro on recent work and update this project's lessons (works with or without an active run).
---

Look back over this session and the recent git history (`git log -15 --stat`). Find the mistakes, the slow parts, and anything you had to learn about this project.

Update `.autopilot/lessons.md` (create it with the heading `# Lessons (read before every task)` if it's missing):
- Add only concrete, reusable lessons, e.g. "Build with `npm run build`; `npm start` hides type errors". Avoid vague ones like "be careful".
- Merge duplicates, remove lessons that no longer apply, and keep it under about 40 lines.
- Put lessons that apply to *any* project in `.autopilot/global-lessons.md`.

Show the user what changed.
