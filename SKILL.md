---
name: it-workshop
description: "Use when the user wants to spin up a multi-agent IT project team. Takes a project description, selects the right roles from 24 IT specialists across 4 departments, creates a workspace with agent definitions, and dispatches a manager agent to orchestrate the team."
---

# IT Workshop — Project Team Generator

You generate a complete multi-agent IT project workspace. The user describes their project, you pick the right team, scaffold the workspace, and hand control to a manager agent who orchestrates the specialists.

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

Ask: **"This is your team. Want to add or remove anyone before I set up the workspace?"**

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
4. **For each selected role, build its skill list:**
   - every skill mapped to the role (plus `_all`) that is in the detected list — match on the full name or on the part after the colon
   - every detected skill that is not in the map but whose description clearly fits the role's job
5. **Tell the user in one short block:** how many skills were detected, which ones each role gets, and which mapped skills are missing on this machine (these are skipped, the team still works without them).

## Step 4: Create Workspace

Once confirmed, scaffold the workspace:

```bash
bash <skill-dir>/scripts/scaffold.sh "<project-name>" "<comma-separated-slugs>"
```

This creates `~/<project-name>/` with a subdirectory for each role (using the exact folder names from the original workshop structure).

### Populate role workspaces

For each selected role, read its definition and write it as the role's SKILL.md:

```bash
# For each role, get its department and slug, then:
cat <skill-dir>/roles/<department>/<slug>.md
# Write the content to:
# ~/<project-name>/<role-folder>/SKILL.md
```

The `<role-folder>` is the `folder` field from the registry (e.g., `DEVELOPPEMENT/FRONTEND`).

Then append the role's skill list from Step 3 to the end of that SKILL.md:

```markdown
## Skills

Before starting any task, invoke each skill below that applies to it (Skill tool), and follow it:

- `<skill-name>` — <one line: when this role uses it>
```

If a role has no detected skills, write `No extra skills detected — work from this role definition.` under the heading.

### Generate project documents

**PROJECT-BRIEF.md** — Read `<skill-dir>/templates/PROJECT-BRIEF.md` and fill in:
- `{{PROJECT_NAME}}` → the project name
- `{{DATE}}` → today's date (YYYY-MM-DD)
- `{{PROJECT_SIZE}}` → small / medium / large
- `{{MANAGER_NAME}}` → name of the selected manager
- `{{PROJECT_DESCRIPTION}}` → the user's project description

Write to `~/<project-name>/PROJECT-BRIEF.md`

**TEAM.md** — Read `<skill-dir>/templates/TEAM.md` and fill in:
- `{{PROJECT_NAME}}` → the project name
- `{{MANAGER_NAME}}` → name of the selected manager
- `{{TEAM_TABLE}}` → markdown table of all selected roles with columns: Role, Department, Slug, Skills (the role's skill list from Step 3, comma-separated)

Write to `~/<project-name>/TEAM.md`

## Step 5: Dispatch the Manager

Launch the manager agent as a subagent using the Agent tool:

```
Agent({
  name: "<manager-slug>",
  description: "Project manager for <project-name>",
  prompt: "<contents of the manager's SKILL.md>\n\n---\n\nYou are managing the project '<project-name>'.\n\n<contents of PROJECT-BRIEF.md>\n\n<contents of TEAM.md>\n\nYour workspace is at ~/<project-name>/. Each team member has their own folder with a SKILL.md defining their role. When you need a specialist, dispatch them as a subagent using the Agent tool — read their SKILL.md and include it in full in the prompt so they know their role and which skills to use. Each SKILL.md ends with a Skills section: tell every specialist to invoke the skills that apply to their task before they start, and use your own listed skills the same way.\n\nStart by reading the project brief, then create a plan and begin dispatching agents to execute it. Report progress back to the user."
})
```

The user now talks to the manager. The manager:
- Reads the project brief
- Breaks down work into tasks
- Dispatches specialist agents (reading each one's SKILL.md, including its Skills section)
- Collects results and reports back

## Role Registry Reference

The full registry of 24 roles lives at `<skill-dir>/roles/registry.json`.

**Departments:**
- **direction** (4 roles): CTO/DSI, Responsable SI, Chef de Projets, Scrum Master
- **developpement** (8 roles): Tech Lead, UX/UI Designer, Frontend, Backend, Mobile Dev, DevOps/SRE, QA/Testeur, DBA
- **cybersecurite** (6 roles): RSSI/CISO, Security Engineer, SOC Analyst, Pentester, GRC/Compliance, Incident Response
- **infrastructure** (6 roles): Admin Réseau, Sysadmin, Cloud Engineer, Support N1-N2, Support N3/Expert, Technicien Poste

Role definitions are at `<skill-dir>/roles/<department>/<slug>.md`.

The role → skill map is at `<skill-dir>/roles/skills-map.json`. Add a skill name under a role slug to make that role use it whenever it is installed.
