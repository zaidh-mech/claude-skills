#!/usr/bin/env bash
# Symlink skills from this repo into Claude Code's skill directories.
#
#   scripts/sync.sh                              link every global/* skill into ~/.claude/skills
#   scripts/sync.sh --project <path> <name>...   link chosen project/* skills into <path>/.claude/skills
#   options: --dry-run   show actions only
#            --prune     remove dangling symlinks in the target that point into this repo
#
# Existing real directories at the destination are never overwritten.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dry=0; prune=0; project=""; names=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry=1 ;;
    --prune) prune=1 ;;
    --project) project="${2:?--project needs a path}"; shift ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) names+=("$1") ;;
  esac
  shift
done

run() { if [[ $dry -eq 1 ]]; then echo "[dry-run] $*"; else "$@"; fi; }

if [[ -n "$project" ]]; then
  [[ -d "$project" ]] || { echo "error: $project is not a directory" >&2; exit 1; }
  target="$(cd "$project" && pwd)/.claude/skills"
  src_root="$REPO/project"
  if [[ ${#names[@]} -eq 0 ]]; then
    echo "error: name the project skills to link, e.g. --project ~/code/app my-skill" >&2
    echo "available:"; ls -1 "$src_root" 2>/dev/null | sed 's/^/  /'
    exit 1
  fi
else
  target="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
  src_root="$REPO/global"
  if [[ ${#names[@]} -eq 0 ]]; then
    shopt -s nullglob
    for d in "$src_root"/*/; do names+=("$(basename "$d")"); done
  fi
fi

run mkdir -p "$target"

linked=0
for n in ${names[@]+"${names[@]}"}; do
  src="$src_root/$n"
  dest="$target/$n"
  if [[ ! -f "$src/SKILL.md" ]]; then echo "skip $n: no $src/SKILL.md"; continue; fi
  if [[ -L "$dest" ]]; then
    [[ "$(readlink "$dest")" == "$src" ]] && { echo "ok   $n"; continue; }
    run ln -sfn "$src" "$dest"; echo "relink $n"
  elif [[ -e "$dest" ]]; then
    echo "skip $n: $dest exists and is not a symlink (move it aside to link)"; continue
  else
    run ln -s "$src" "$dest"; echo "link $n -> $dest"
  fi
  linked=$((linked + 1))
done

if [[ $prune -eq 1 ]]; then
  for l in "$target"/*; do
    [[ -L "$l" ]] || continue
    dst="$(readlink "$l")"
    if [[ "$dst" == "$REPO/"* && ! -e "$l" ]]; then run rm "$l"; echo "prune $(basename "$l")"; fi
  done
fi

echo "done: $linked changed, target $target"
