---
name: it-workshop
description: "Use when the user wants to spin up a multi-agent IT project team. Takes a project description, selects the right roles from 24 IT specialists across 4 departments, sets up the project folder, acts as the manager, and gives every specialist its own session."
---

# IT Workshop — Project Team Generator

You run a multi-agent IT project team. The user describes their project, you pick the right team, set up the project folder, become the manager, and give every specialist its own session to work in.

## Step 1: Project Intake

Ask the user to describe their project. If they already provided a description, use it directly.

Gather:
- **Project name** (short slug, e.g. "ecommerce-platform")
- **Project description** (what they want to build)

If the user gave a description but no name, derive one from it.

## Step 2: Analyze Scope & Select Team

### Determine project size

| Size | Examples | Team size |
|------|----------|-----------|
| **small** | Landing page, portfolio, simple website, one-page app, static site | 3–5 agents |
| **medium** | Web app, API + frontend, SaaS MVP, mobile app, internal tool | 6–12 agents |
| **large** | Platform, microservices architecture, enterprise system, multi-app ecosystem | 12–24 agents |

### Select roles from the registry

Load the role registry:
```
cat <skill-dir>/roles/registry.json
```

For each role in the registry, include it if:
1. The project description matches any of the role's `keywords`
2. The role's `min_size` is <= the determined project size (small < medium < large)

**Size ordering:** small=1, medium=2, large=3. A role with min_size "medium" is only included if project size is medium or large.

**Always include:**
- At least one manager (`is_manager: true`) — pick by `manager_priority` (1 = highest)
- At least one development role (frontend or backend)

### Manager selection
- If project is **large** AND `cto-dsi` was selected → CTO/DSI is the manager
- Otherwise → `chef-de-projets` is the manager (priority 1)
- The non-managing manager role can still be on the team as a specialist

### Present the team for confirmation

Show the user the proposed team as a table:

| Role | Department | Why |
|------|------------|-----|
| Chef de Projets | Direction | Manager — coordinates all agents |
| Frontend Developer | Développement | React UI components |
| Backend Developer | Développement | API and business logic |
| ... | ... | ... |

Ask: **"This is your team. Want to add or remove anyone before I set up the project?"**

Wait for confirmation. Adjust if they request changes.

## Step 3: Detect Available Skills

Every agent on the team works with the skills installed in this session, so find out what is there before building the workspace.

1. **Read your own available-skills list.** It is the authoritative source: every skill name the session offers, including plugin skills written as `plugin:skill`.
2. **Add what is on disk:**
   ```bash
   bash <skill-dir>/scripts/detect-skills.sh
   ```
   Merge these names into the list (a disk name `deploy` and a session name `vercel:deploy` are the same skill).
3. **Load the role → skill map:** `cat <skill-dir>/roles/skills-map.json`. Each key is a role slug; `_all` applies to every role.
4. **Load the bundled skills index:** `cat <skill-dir>/skills/index.json`. It lists every skill shipped inside this skill, with the path to its SKILL.md.
5. **For each selected role, build its skill list:**
   - every skill mapped to the role (plus `_all`) that is in the detected list — match on the full name or on the part after the colon. Mark it **installed**.
   - every mapped skill that is not installed but is in the bundled index. Mark it **bundled** and keep its path `<skill-dir>/<path from index>`.
   - every detected skill that is not in the map but whose description clearly fits the role's job. Mark it **installed**.
6. **Tell the user in one short block:** how many skills were detected, how many come from the bundle, which ones each role gets, and which mapped skills are neither installed nor bundled (these are skipped, the team still works without them).

To install the bundled skills permanently, the user can run `bash <skill-dir>/scripts/install-skills.sh` (it never overwrites a skill that already exists).

## Step 4: Create the Project Folder

The project folder holds **the project only**. Role definitions and skills stay in this skill's folder and are read from there. Never copy a role file, a SKILL.md or a skill into the project.

1. Create `<current-folder>/<project-name>/`. This is where the team's deliverables go (code, docs, assets).
2. Create `<current-folder>/<project-name>/.workshop/` with two small files, so the team can be resumed in a later session:

**`.workshop/PROJECT-BRIEF.md`** — Read `<skill-dir>/templates/PROJECT-BRIEF.md` and fill in:
- `{{PROJECT_NAME}}` → the project name
- `{{DATE}}` → today's date (YYYY-MM-DD)
- `{{PROJECT_SIZE}}` → small / medium / large
- `{{MANAGER_NAME}}` → name of the selected manager
- `{{PROJECT_DESCRIPTION}}` → the user's project description

**`.workshop/TEAM.md`** — Read `<skill-dir>/templates/TEAM.md` and fill in:
- `{{PROJECT_NAME}}` → the project name
- `{{MANAGER_NAME}}` → name of the selected manager
- `{{TEAM_TABLE}}` → markdown table of all selected roles with columns: Role, Department, Role file (absolute path `<skill-dir>/roles/<department>/<slug>.md`), Skills (the role's list from Step 3: `name (installed)` or `name (bundled: <absolute path to its SKILL.md>)`)

Create nothing else: no role folders, no `templates/` or `scripts/` folders.

## Step 5: Become the Manager

**You are the manager.** Do not dispatch the manager as a subagent: this session is the manager's room, and the user talks to the manager here.

1. Read the manager's role file `<skill-dir>/roles/direction/<manager-slug>.md` and adopt it.
2. Load the manager's own skills from Step 3.
3. Break the project into tasks: description, acceptance criteria, dependencies, assigned role.
4. Show the plan to the user in a few lines, then start dispatching.

## Step 6: Give Every Agent Its Own Room

Each specialist works in **its own separate session**, so the user can open any agent's room from the sidebar, read what it is doing and talk to it directly.

**How to dispatch a specialist:**

1. **If this session can start a separate (nested) session** — a task that opens as its own session under this one in the sidebar and reports back — use that. One session per specialist, started in the project folder.
2. **Otherwise** use the Agent tool (a subagent). Say once to the user that agents are running inside this session because separate sessions are not available here.

Never start two rooms for the same role: reuse the role's existing session for its next task.

**Name every room** `<Role name> — <project-name>` (for example `Frontend — hello-page`).

**Give every room this prompt:**

```
You are the <Role name> on the project "<project-name>".

1. Read your role definition and adopt it: <skill-dir>/roles/<department>/<slug>.md
2. Read the brief and the team: <project-folder>/.workshop/PROJECT-BRIEF.md and TEAM.md
3. Load your skills before you start:
   - <skill-name> (installed) → invoke it with the Skill tool
   - <skill-name> (bundled) → read <absolute path to its SKILL.md> and follow it
4. Your task: <task description>
   Done when: <acceptance criteria>

Write deliverables into <project-folder>/ only. Do not copy role files or skills into it.
When finished, report back to the manager: what you did, files created or changed, anything blocking.
```

**Then, as manager:**
- Dispatch independent tasks at the same time, dependent ones in order.
- When a room reports back, review the deliverable against its acceptance criteria. Send it back to the same room if it falls short.
- Keep the user updated: what is done, what is running, what is next.
- Only the manager talks across roles. Specialists report to the manager, not to each other.

## Role Registry Reference

The full registry of 24 roles lives at `<skill-dir>/roles/registry.json`.

**Departments:**
- **direction** (4 roles): CTO/DSI, Responsable SI, Chef de Projets, Scrum Master
- **developpement** (8 roles): Tech Lead, UX/UI Designer, Frontend, Backend, Mobile Dev, DevOps/SRE, QA/Testeur, DBA
- **cybersecurite** (6 roles): RSSI/CISO, Security Engineer, SOC Analyst, Pentester, GRC/Compliance, Incident Response
- **infrastructure** (6 roles): Admin Réseau, Sysadmin, Cloud Engineer, Support N1-N2, Support N3/Expert, Technicien Poste

Role definitions are at `<skill-dir>/roles/<department>/<slug>.md`.

Bundled third-party skills live in `<skill-dir>/skills/` (index: `skills/index.json`, credits and licenses: `skills/README.md`).

The role → skill map is at `<skill-dir>/roles/skills-map.json`. Add a skill name under a role slug to make that role use it whenever it is installed.
