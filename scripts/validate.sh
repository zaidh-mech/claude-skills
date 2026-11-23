#!/usr/bin/env bash
# Validate skill folders: SKILL.md exists, frontmatter has name + description,
# name matches folder, scripts are executable.
# Usage: scripts/validate.sh [skill-dir ...]   (default: all of global/* and project/*)
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"

if [[ $# -gt 0 ]]; then
  dirs=("$@")
else
  shopt -s nullglob
  dirs=(global/*/ project/*/)
fi

fail=0
checked=0
err() { echo "  ✗ $1"; fail=1; }

for d in ${dirs[@]+"${dirs[@]}"}; do
  d="${d%/}"
  folder="$(basename "$d")"
  echo "$d"
  checked=$((checked + 1))
  f="$d/SKILL.md"
  if [[ ! -f "$f" ]]; then err "missing SKILL.md"; continue; fi

  if [[ "$(head -n1 "$f")" != "---" ]]; then err "SKILL.md must start with '---' frontmatter"; continue; fi
  fm="$(awk 'NR==1{next} /^---$/{exit} {print}' "$f")"

  name="$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -n1 | tr -d '"'"'")"
  desc="$(printf '%s\n' "$fm" | sed -n 's/^description:[[:space:]]*//p' | head -n1)"

  [[ -z "$name" ]] && err "frontmatter missing 'name'"
  [[ -n "$name" && "$name" != "$folder" ]] && err "name '$name' does not match folder '$folder'"
  [[ -n "$name" && ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] && err "name must be kebab-case"
  [[ -z "$desc" ]] && err "frontmatter missing 'description'"
  [[ ${#desc} -gt 1024 ]] && err "description is ${#desc} chars (keep under 1024)"
  grep -q 'SKILL_NAME\|SKILL_TITLE\|One or two sentences on what this skill does' "$f" && err "template placeholders still present"

  lines=$(wc -l < "$f")
  [[ $lines -gt 500 ]] && echo "  ! SKILL.md is $lines lines; consider moving detail into references/"

  if [[ -d "$d/scripts" ]]; then
    while IFS= read -r s; do
      [[ -x "$s" ]] || err "not executable: $s"
    done < <(find "$d/scripts" -type f ! -name '.gitkeep')
  fi
done

if [[ $checked -eq 0 ]]; then echo "no skills found"; fi
[[ $fail -eq 0 ]] && echo "ok ($checked checked)"
exit $fail
