#!/usr/bin/env bash
#
# Build a GitHub Actions matrix JSON describing every template project
# in the repository root.
#
# A template project is a top-level directory (excluding .github and .git)
# that contains at least one .tf file and a README.md with a display_name
# front-matter field.
#
# The Coder template name is the display_name converted to dash case:
#   "Generic Ubuntu Workspace" -> "generic-ubuntu-workspace"
#
# Output: {"include":[{"directory":"...","name":"..."},...]}
#         written to $GITHUB_OUTPUT (or stdout when unset).

set -euo pipefail

# Convert a display name into a dash-case slug.
slugify() {
  echo "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g'
}

# Print the display_name from a README's YAML front matter.
get_display_name() {
  local readme="$1"
  awk '/^display_name:/{sub(/^display_name:[ ]*/,""); gsub(/"/,""); print; exit}' "$readme" 2>/dev/null
}

# Succeed if a directory contains at least one .tf file.
has_tf_files() {
  compgen -G "$1/*.tf" > /dev/null
}

# Succeed if a directory has a README.md.
has_readme() {
  [ -f "$1/README.md" ]
}

# List template project directories (relative, no ./ prefix), sorted.
find_template_dirs() {
  find . -maxdepth 1 -mindepth 1 -type d \
    -not -path './.github*' \
    -not -path './.git*' \
    | sort
}

# Append one {"directory":...,"name":...} entry to the running list.
add_template() {
  local directory="$1"
  local name="$2"
  templates=$(printf '%s\n{"directory":"%s","name":"%s"}\n' "$templates" "$directory" "$name")
}

# Iterate over directories and collect matrix entries.
collect_templates() {
  local d display_name slug
  templates=""
  while IFS= read -r d; do
    d=${d#./}
    if ! has_tf_files "$d"; then
      continue
    fi
    if ! has_readme "$d"; then
      echo "::warning::$d has no README.md; skipping" >&2
      continue
    fi
    display_name=$(get_display_name "$d/README.md")
    if [ -z "$display_name" ]; then
      echo "::warning::$d/README.md has no display_name; skipping" >&2
      continue
    fi
    slug=$(slugify "$display_name")
    add_template "$d" "$slug"
  done < <(find_template_dirs)
}

# Emit the matrix JSON to $GITHUB_OUTPUT when available.
set_matrix_output() {
  local json
  json=$(printf '%s' "$templates" | sed '/^$/d' | jq -s -c '.')
  echo "Templates found: $json" >&2
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "matrix={\"include\":$json}" >> "$GITHUB_OUTPUT"
  else
    echo "$json"
  fi
}

main() {
  collect_templates
  set_matrix_output
}

main "$@"
