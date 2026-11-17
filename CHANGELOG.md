# Changelog

## 1.1.0 — 2026-11-17

Token-cost redesign.

- Three modes: solo (small projects), team (subagents), rooms (one session per agent, on request)
- Team caps by size (5 medium, 8 large) and a cost confirmation before dispatch
- `SKILL.md` cut from 9 KB to under 4 KB; team rules moved to `references/team-mode.md`
- `registry.json` and `skills-map.json` replaced by `roles/roles.tsv` and `roles/skills.txt` (no `jq`)
- Agents get paths instead of pasted content, load at most 2 skills, and report in 10 lines with evidence
- New: `preview`, forcing roles in or out, `.workshop/STATE.md` for resuming, `scripts/check.sh`
- Removed the unused `folder` field (and its typos) and the disk scan for skills

## 1.0.0 — 2026-11-16

First release: 24 roles, skill detection, bundled skills, manager and agent sessions.
