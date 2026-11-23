#!/usr/bin/env bash
# Scaffold a new skill from templates/skill.
# Usage: scripts/new-skill.sh <kebab-case-name> [global|project]
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
name="${1:-}"
scope="${2:-global}"

if [[ ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "error: name must be kebab-case (got '${name}')" >&2
  exit 1
fi
if [[ "$scope" != "global" && "$scope" != "project" ]]; then
  echo "error: scope must be 'global' or 'project'" >&2
  exit 1
fi

dest="$REPO/$scope/$name"
if [[ -e "$dest" ]]; then
  echo "error: $dest already exists" >&2
  exit 1
fi

cp -R "$REPO/templates/skill" "$dest"
title="$(echo "$name" | awk -F- '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')"
sed -i.bak -e "s/SKILL_NAME/$name/" -e "s/SKILL_TITLE/$title/" "$dest/SKILL.md" && rm -f "$dest/SKILL.md.bak"

echo "created $scope/$name"
echo "next: edit $scope/$name/SKILL.md, then run scripts/validate.sh $scope/$name"
