Describe 'Worktree support scripts existence and permissions'
  It 'worktree-manager.sh exists and is executable'
    Path script="core/scripts/worktree-manager.sh"
    The path script should be exist
    The path script should be executable
  End

  It 'backlog-update.sh exists and is executable'
    Path script="core/scripts/backlog-update.sh"
    The path script should be exist
    The path script should be executable
  End

  It 'worktree-env-setup.sh exists and is executable'
    Path script="core/scripts/worktree-env-setup.sh"
    The path script should be exist
    The path script should be executable
  End
End
