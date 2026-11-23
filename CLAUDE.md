# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repo is a version-controlled library of custom Claude Code skills (`SKILL.md` modules), focused on engineering work. Nothing here is built or deployed; skills are symlinked into the owner's local machine, where Claude Code discovers them. Work in this repo means scaffolding new skills, refining existing `SKILL.md` files, and maintaining their `references/` and `scripts/` folders.

## Layout and scope

- `global/<skill-name>/` holds skills meant for every project. They are linked into `~/.claude/skills/`.
- `project/<skill-name>/` holds skills meant only for specific codebases. They are linked into `<that-project>/.claude/skills/` on demand, never globally.
- `templates/skill/` is the starting point for a new skill. Copy it with `scripts/new-skill.sh`, don't hand-create folders.
- Folder name must equal the `name` in frontmatter (kebab-case). Claude Code identifies the skill by that name, and the sync script links by folder name.

## Commands

```bash
scripts/new-skill.sh <name> [global|project]     # scaffold from templates/skill (default: global)
scripts/validate.sh                              # check every skill's frontmatter and layout
scripts/validate.sh global/<name>                # check one skill
scripts/sync.sh                                  # symlink all global/* into ~/.claude/skills
scripts/sync.sh --project <path> <name>...       # symlink chosen project/* skills into <path>/.claude/skills
scripts/sync.sh --dry-run                        # show what would change
scripts/sync.sh --prune                          # also remove dangling links that point into this repo
```

`sync.sh` creates symlinks, so edits in this repo are live immediately in Claude Code. It never overwrites a real (non-symlink) directory at the destination; it warns and skips instead. Run `validate.sh` before committing.

## Skill authoring conventions

- **Frontmatter**: only `name` and `description` are required. The `description` is what Claude reads to decide whether to load the skill, so write it trigger-first: what the skill does plus the concrete phrases, file types, or situations that should invoke it. Keep it under ~1024 characters.
- **Body**: concise, procedural, imperative steps. Aim for under ~500 lines; the body is loaded into context every time the skill fires.
- **Progressive disclosure**: put long material (specs, standards tables, formulas, API details, examples) in `references/*.md` and point to it from the body with a line saying when to read it. Put deterministic work (calculations, file conversion, checks) in `scripts/` and tell Claude to run it rather than reimplement it.
- Reference supporting files by relative path from the skill folder (e.g. `references/tolerances.md`, `scripts/convert.py`).
- Scripts must be executable (`chmod +x`), have a shebang, and take inputs as arguments rather than prompting.
- Don't duplicate content between `SKILL.md` and `references/`; the body should summarize and link.
