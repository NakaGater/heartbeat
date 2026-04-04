# Task 6, CC1-CC3: 直接呼出/手動呼出スクリプトのエラーハンドリング標準化
# 直接呼出/手動呼出スクリプト = set -euo pipefail
# Design spec 29-30 (AC-5)

BACKLOG_UPDATE="core/scripts/backlog-update.sh"
WORKTREE_MANAGER="core/scripts/worktree-manager.sh"
INSIGHTS_AGGREGATE="core/scripts/insights-aggregate.sh"

# --- ヘルパー関数 ---

# backlog-update.sh に set -euo pipefail が含まれているか
check_backlog_has_strict_mode() {
  grep -q '^set -euo pipefail' "$BACKLOG_UPDATE"
}

# worktree-manager.sh に set -euo pipefail が含まれているか
check_worktree_manager_has_strict_mode() {
  grep -q '^set -euo pipefail' "$WORKTREE_MANAGER"
}

# insights-aggregate.sh に set -euo pipefail が含まれているか
check_insights_has_strict_mode() {
  grep -q '^set -euo pipefail' "$INSIGHTS_AGGREGATE"
}

Describe '直接呼出/手動呼出スクリプトのエラーハンドリング標準化 (AC-5)'

  Describe 'backlog-update.sh (CC1)'
    It 'set -euo pipefail が含まれている'
      When call check_backlog_has_strict_mode
      The status should be success
    End
  End

  Describe 'worktree-manager.sh (CC2)'
    It 'set -euo pipefail が含まれている'
      When call check_worktree_manager_has_strict_mode
      The status should be success
    End
  End

  Describe 'insights-aggregate.sh (CC3)'
    It 'set -euo pipefail が含まれている'
      When call check_insights_has_strict_mode
      The status should be success
    End
  End
End
