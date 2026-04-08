SHELLSPEC_CONFIG=".shellspec"

# --- ヘルパー関数 ---

# --jobs 4 が含まれていること
check_jobs_option() {
  grep -q '^--jobs 4$' "$SHELLSPEC_CONFIG"
}

# --format が progress であること
check_format_progress() {
  grep -q '^--format progress$' "$SHELLSPEC_CONFIG"
}

# --require spec_helper が維持されていること
check_require_spec_helper() {
  grep -q '^--require spec_helper$' "$SHELLSPEC_CONFIG"
}

# --warning-as-failure が維持されていること
check_warning_as_failure() {
  grep -q '^--warning-as-failure$' "$SHELLSPEC_CONFIG"
}

Describe '.shellspec 並列実行設定 (Task 1)'
  Describe '並列実行オプション'
    It '.shellspec に --jobs 4 が含まれている'
      When call check_jobs_option
      The status should be success
    End
  End

  Describe '出力フォーマット'
    It '.shellspec の --format が progress である'
      When call check_format_progress
      The status should be success
    End
  End

  Describe '既存オプションの保全'
    It '--require spec_helper が維持されている'
      When call check_require_spec_helper
      The status should be success
    End

    It '--warning-as-failure が維持されている'
      When call check_warning_as_failure
      The status should be success
    End
  End
End
