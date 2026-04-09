# Task 6, CC1-CC3: Error handling standardization for directly invoked scripts
# Directly invoked scripts = set -euo pipefail
# Design spec 29-30 (AC-5)

BACKLOG_UPDATE="core/scripts/backlog-update.sh"
WORKTREE_MANAGER="core/scripts/worktree-manager.sh"
INSIGHTS_AGGREGATE="core/scripts/insights-aggregate.sh"

# --- Helper functions ---

# Check backlog-update.sh contains set -euo pipefail
check_backlog_has_strict_mode() {
  grep -q '^set -euo pipefail' "$BACKLOG_UPDATE"
}

# Check worktree-manager.sh contains set -euo pipefail
check_worktree_manager_has_strict_mode() {
  grep -q '^set -euo pipefail' "$WORKTREE_MANAGER"
}

# Check insights-aggregate.sh contains set -euo pipefail
check_insights_has_strict_mode() {
  grep -q '^set -euo pipefail' "$INSIGHTS_AGGREGATE"
}

Describe 'Error Handling Standardization for Directly Invoked Scripts (AC-5)'

  Describe 'backlog-update.sh (CC1)'
    It 'contains set -euo pipefail'
      When call check_backlog_has_strict_mode
      The status should be success
    End
  End

  Describe 'worktree-manager.sh (CC2)'
    It 'contains set -euo pipefail'
      When call check_worktree_manager_has_strict_mode
      The status should be success
    End
  End

  Describe 'insights-aggregate.sh (CC3)'
    It 'contains set -euo pipefail'
      When call check_insights_has_strict_mode
      The status should be success
    End
  End
End
