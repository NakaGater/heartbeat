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
