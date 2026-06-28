#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${CONFIG_FILE:-/home/nutanix/ntnxlabs/mkdocs/repo-sync/repos.conf}"
DOCS_ROOT="${DOCS_ROOT:-/mnt/nutanix_docs/Docs}"
INDEX_FILE="${INDEX_FILE:-$DOCS_ROOT/index.md}"

urlencode_path() {
  python3 - "$1" <<'PY'
import sys
from urllib.parse import quote
print(quote(sys.argv[1]))
PY
}

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Config file not found: $CONFIG_FILE" >&2
  exit 1
fi

rebuild_home_index() {
  local section
  local -a sections=()

  while IFS= read -r section; do
    sections+=("$section")
  done < <(
    find "$DOCS_ROOT" -mindepth 1 -maxdepth 1 -type d \
      ! -name '.*' \
      ! -name 'assets' \
      | while IFS= read -r path; do
          basename "$path"
        done \
      | sort -f
  )

  {
    echo "# Notes"
    echo
    echo "## Folders"
    echo
    for section in "${sections[@]}"; do
      echo "- [$section]($section/index.md)"
    done
    echo
  } > "$INDEX_FILE"

  echo "Updated home index: $INDEX_FILE"
}

rebuild_section_indexes() {
  local section_dir section_name section_index rel first_md
  local -a subdirs=() root_files=()

  while IFS= read -r section_dir; do
    section_name="$(basename "$section_dir")"
    section_index="$section_dir/index.md"
    subdirs=()
    root_files=()

    while IFS= read -r rel; do
      subdirs+=("$rel")
    done < <(
      find "$section_dir" -mindepth 1 -maxdepth 1 -type d ! -name '.*' \
        | while IFS= read -r d; do
            basename "$d"
          done \
        | sort -f
    )

    while IFS= read -r rel; do
      root_files+=("$(basename "$rel")")
    done < <(
      find "$section_dir" -mindepth 1 -maxdepth 1 -type f -name '*.md' ! -name 'index.md' | sort -f
    )

    {
      echo "# $section_name"
      echo

      if [[ "${#subdirs[@]}" -gt 0 ]]; then
        echo "## Folders"
        echo
        for rel in "${subdirs[@]}"; do
          if [[ -f "$section_dir/$rel/index.md" ]]; then
            echo "- [$rel]($(urlencode_path "$rel")/index.md)"
          else
            first_md="$(find "$section_dir/$rel" -type f -name '*.md' | sort -f | head -n 1)"
            if [[ -n "${first_md:-}" ]]; then
              first_md="${first_md#"$section_dir/"}"
              echo "- [$rel]($(urlencode_path "$first_md"))"
            fi
          fi
        done
        echo
      fi

      if [[ "${#root_files[@]}" -gt 0 ]]; then
        echo "## Files"
        echo
        for rel in "${root_files[@]}"; do
          echo "- [$rel]($(urlencode_path "$rel"))"
        done
        echo
      fi
    } > "$section_index"

    echo "Updated section index: $section_index"
  done < <(
    find "$DOCS_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name '.*' ! -name 'assets' | sort -f
  )
}

while IFS='|' read -r section repo_name repo_url; do
  [[ -z "${section:-}" ]] && continue
  [[ "${section:0:1}" == "#" ]] && continue

  section="$(echo "$section" | xargs)"
  repo_name="$(echo "$repo_name" | xargs)"
  repo_url="$(echo "$repo_url" | xargs)"

  if [[ -z "$section" || -z "$repo_name" || -z "$repo_url" ]]; then
    echo "Skipping invalid config line for repo: '$section|$repo_name|$repo_url'" >&2
    continue
  fi

  target_dir="$DOCS_ROOT/$section/$repo_name"
  mkdir -p "$DOCS_ROOT/$section"

  if [[ -d "$target_dir/.git" ]]; then
    echo "Updating: $target_dir"
    git -c safe.directory="$target_dir" -C "$target_dir" fetch --prune origin
    git -c safe.directory="$target_dir" -C "$target_dir" pull --ff-only origin
  else
    echo "Cloning: $repo_url -> $target_dir"
    git clone --depth 1 "$repo_url" "$target_dir"
  fi
done < "$CONFIG_FILE"

rebuild_home_index
rebuild_section_indexes
