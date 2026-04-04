# Shared test helpers for heartbeat spec tests

setup_retro_env() {
  export HEARTBEAT_RETRO_LOG=$(mktemp)
  export HEARTBEAT_INSIGHTS=$(mktemp)
}

cleanup_retro_env() {
  rm -f "$HEARTBEAT_RETRO_LOG" "$HEARTBEAT_INSIGHTS"
  unset HEARTBEAT_RETRO_LOG HEARTBEAT_INSIGHTS
}

# Check if a string contains Japanese characters (hiragana, katakana, kanji)
has_japanese() {
  [ -n "$1" ] && printf '%s' "$1" | grep -qE '[ぁ-んァ-ヶ一-龥]'
}

# Extract content under a ## heading from a Markdown file
# Usage: extract_skill_section <file_path> <section_name>
# Returns the content between ## <section_name> and the next ## heading (or EOF)
extract_skill_section() {
  local file_path="$1"
  local section_name="$2"
  [ -n "$section_name" ] || return 1
  [ -f "$file_path" ] || return 1
  awk -v section="$section_name" '
    /^## / {
      if (found) exit
      if ($0 == "## " section) { found=1; next }
      next
    }
    found { print }
  END { if (!found) exit 1 }
  ' "$file_path"
}
