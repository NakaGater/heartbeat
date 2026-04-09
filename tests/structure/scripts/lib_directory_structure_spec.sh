# Task 7: lib/ directory structure test (AC-6)
# Verify existence, file layout, and library patterns of core/scripts/lib/

LIB_DIR="core/scripts/lib"
COMMON_SH="$LIB_DIR/common.sh"
COMMIT_MSG_SH="$LIB_DIR/commit-message.sh"

# --- Helper functions ---

# Check lib/ directory exists
check_lib_dir_exists() {
  [ -d "$LIB_DIR" ]
}

# Check common.sh exists
check_common_sh_exists() {
  [ -f "$COMMON_SH" ]
}

# Check commit-message.sh exists
check_commit_message_sh_exists() {
  [ -f "$COMMIT_MSG_SH" ]
}

# Check common.sh can be sourced without syntax errors
check_common_sh_sourceable() {
  bash -n "$COMMON_SH"
}

# Check commit-message.sh can be sourced without syntax errors
check_commit_message_sh_sourceable() {
  bash -n "$COMMIT_MSG_SH"
}

# Check common.sh defines find_board_jsonl
check_common_has_find_board_jsonl() {
  grep -q '^find_board_jsonl()' "$COMMON_SH"
}

# Check common.sh defines acquire_lock
check_common_has_acquire_lock() {
  grep -q '^acquire_lock()' "$COMMON_SH"
}

# Check common.sh defines release_lock
check_common_has_release_lock() {
  grep -q '^release_lock()' "$COMMON_SH"
}

# Check commit-message.sh defines format_commit_message
check_commit_msg_has_format() {
  grep -q '^format_commit_message()' "$COMMIT_MSG_SH"
}

# Check common.sh has no side effects (no stdout) when sourced
check_common_no_side_effects() {
  local output
  output=$(bash -c 'source "'"$COMMON_SH"'"' 2>&1)
  [ -z "$output" ]
}

# Check commit-message.sh has no side effects (no stdout) when sourced
check_commit_message_no_side_effects() {
  local output
  output=$(bash -c 'source "'"$COMMIT_MSG_SH"'"' 2>&1)
  [ -z "$output" ]
}

Describe 'lib/ Directory Structure Test (AC-6)'

  Describe 'Directory and File Existence (CC1/CC2)'
    It 'core/scripts/lib/ directory exists'
      When call check_lib_dir_exists
      The status should be success
    End

    It 'lib/common.sh exists'
      When call check_common_sh_exists
      The status should be success
    End

    It 'lib/commit-message.sh exists'
      When call check_commit_message_sh_exists
      The status should be success
    End
  End

  Describe 'File Sourceability (CC1/CC2)'
    It 'common.sh can be sourced without syntax errors'
      When call check_common_sh_sourceable
      The status should be success
    End

    It 'commit-message.sh can be sourced without syntax errors'
      When call check_commit_message_sh_sourceable
      The status should be success
    End
  End

  Describe 'common.sh Required Function Definitions (CC3)'
    It 'find_board_jsonl function is defined'
      When call check_common_has_find_board_jsonl
      The status should be success
    End

    It 'acquire_lock function is defined'
      When call check_common_has_acquire_lock
      The status should be success
    End

    It 'release_lock function is defined'
      When call check_common_has_release_lock
      The status should be success
    End
  End

  Describe 'commit-message.sh Required Function Definitions (CC3)'
    It 'format_commit_message function is defined'
      When call check_commit_msg_has_format
      The status should be success
    End
  End

  Describe 'Library Pattern -- No Side Effects on Source (CC4)'
    It 'common.sh produces no output when sourced'
      When call check_common_no_side_effects
      The status should be success
    End

    It 'commit-message.sh produces no output when sourced'
      When call check_commit_message_no_side_effects
      The status should be success
    End
  End
End
