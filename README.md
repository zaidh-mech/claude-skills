# claude-skills

Personal library of Claude Code skills for engineering work.

- `global/` skills are linked into `~/.claude/skills/` and available in every project.
- `project/` skills are linked into a specific project's `.claude/skills/`.

## Setup

```bash
git clone <this-repo> ~/code/claude-skills
cd ~/code/claude-skills
scripts/sync.sh            # link all global skills
```

Because skills are symlinked, `git pull` is all it takes to update them. Restart Claude Code (or start a new session) to pick up newly added skills.

## New skill

```bash
scripts/new-skill.sh my-skill            # or: scripts/new-skill.sh my-skill project
# edit global/my-skill/SKILL.md
scripts/validate.sh global/my-skill
scripts/sync.sh
```

For a project-only skill: `scripts/sync.sh --project ~/code/some-app my-skill`.

See `CLAUDE.md` for authoring conventions.
