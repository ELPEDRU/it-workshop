# Team and rooms mode

You are the manager. Read your role file `<skill-dir>/roles/direction/<manager-slug>.md` and adopt it. Do not dispatch a manager agent.

## Plan

Break the project into tasks and write them to `.workshop/STATE.md`. Each task has one owner, a clear "done when", and the files or folders it may touch. Two tasks that run at the same time must not touch the same files; if they must, run them one after the other.

Agree shared contracts (API shapes, data schema, file layout) in `PROJECT-BRIEF.md` **before** dispatching parallel work.

If the project is an existing repository: check for uncommitted changes first and tell the user before any agent edits files.

## Dispatch

- **team mode:** use the Agent tool (subagents). Give specialists a cheaper model than your own when the tool lets you choose one.
- **rooms mode:** start each specialist as a separate session named `<Role> — <project>`, if this session can start one. If it cannot, say so once and use subagents.

Run at most 3 agents at the same time. One agent per role: send a role's next task to the same agent.

Prompt for every agent — paths only, nothing pasted:

```
You are the <Role name> on "<project>".
Role: read <skill-dir>/roles/<department>/<slug>.md
Brief: read <project>/.workshop/PROJECT-BRIEF.md
Skills (load at most 2, only if this task needs them): <name> → Skill tool | <name> → read <path>
Task <id>: <description>
Done when: <acceptance criteria>
You may change: <files or folders>. Write nothing outside <project>/.

Report in 10 lines or fewer:
STATUS: done | blocked
FILES: created / changed
EVIDENCE: command run and its result, or how you checked it
NOTES: decisions, problems, what the next role needs to know
```

## Review

When an agent reports:
1. Check the evidence against "done when". No evidence means not done: send it back to the same agent once, with what is missing.
2. Update the task's line in `STATE.md`.
3. Stop and ask the user if a task fails twice, if agents disagree on a shared contract, or if the scope changes.

Keep the user updated in one or two lines per completed task. Specialists report to you, not to each other.
