---
name: it-workshop
description: "Use when the user wants an IT project team to build something: describes a project and wants roles picked, work planned and specialists dispatched. Also for 'preview the team', 'resume the workshop', or asking for a room per agent."
---

# IT Workshop

Pick the smallest team that can deliver the project, then run it in the cheapest mode that fits. `<skill-dir>` is the folder containing this file.

**Token rules — these override everything below:**
- Read a file only when a step tells you to. Never read `skills/`, `roles/skills.txt` or a role file "to get context".
- Pass agents **paths**, never file contents.
- An agent loads at most **2 skills**, and only when its task needs them. The manager loads none in solo mode.
- Ask for confirmation once, before dispatching, with the number of agents and sessions.

## 1. Intake

Get the project name (short slug) and description. Derive the name if missing. Note anything the user rules out ("no mobile app", "no Docker") and any role they force in or out.

If the user says **preview** (or dry run): do steps 1–3, show the result, create nothing, stop.
If `<project>/.workshop/STATE.md` already exists: read it and resume from there instead of starting over.

## 2. Size, mode and team

| Size | Examples | Mode | Team cap |
|------|----------|------|----------|
| small | landing page, script, one-page app, small fix | **solo** | 1–2 roles |
| medium | web app, API + frontend, MVP, internal tool | **team** | 5 agents |
| large | platform, microservices, multi-app system | **team** | 8 agents |

The user can override the mode or the cap. **Rooms** (one visible session per agent) are used only when the user asks for them: they cost the most.

Read `<skill-dir>/roles/roles.tsv` (24 lines). Select a role when:
- the project genuinely needs its job — keywords are hints, your understanding of the project decides
- its `min_size` is not above the project size
- the user did not rule it out

Always include one manager (`cto-dsi` only for large projects, otherwise `chef-de-projets`) and one development role. Then cut down to the cap: drop the roles whose work another selected role can cover.

## 3. Confirm

Show one compact block and wait for a yes:

```
Project: <name> (<size>) — mode: <solo | team | rooms>
Team: <role> — <why, 5 words> ...
Left out: <roles considered but not needed>
Cost: <N> agents, <N> extra sessions. Skills: max 2 per agent.
```

## 4. Set up

Create `<current-folder>/<project>/` for deliverables, and `<project>/.workshop/` with:
- `PROJECT-BRIEF.md` and `TEAM.md`, filled from `<skill-dir>/templates/` (TEAM table columns: Role, Role file path, Skills)
- `STATE.md`: one line per task — `id | role | task | status | evidence`

Get the team's skills with one command, and keep only those available (installed in this session, or bundled):

```bash
bash <skill-dir>/scripts/team-skills.sh <slug> <slug> ...
```

Never copy role files or skills into the project.

## 5. Run

**Solo mode** — you do the work yourself, in this session:
1. Read the role file of the one role doing the work: `<skill-dir>/roles/<department>/<slug>.md`.
2. Load at most 1 skill if the task clearly needs it.
3. Build the deliverable, verify it, update `STATE.md`, report.

**Team or rooms mode** — read `<skill-dir>/references/team-mode.md` now and follow it.

## 6. Done means evidence

A task is done only with proof: files created or changed, plus the command output, test result or check that shows it works. Record it in `STATE.md`. Finish with a summary of 5 lines or fewer: what was built, where, what was verified, what is left.
