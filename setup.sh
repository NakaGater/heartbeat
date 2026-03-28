#!/bin/bash
# Heartbeat development setup
# Checks prerequisites and installs test tooling

set -e

echo "=== Heartbeat Setup ==="
echo ""

# Check jq
if command -v jq &>/dev/null; then
  echo "✓ jq $(jq --version 2>&1)"
else
  echo "✗ jq not found. Install with: brew install jq (macOS) or apt-get install jq (Linux)"
  exit 1
fi

# Check/install ShellSpec
if command -v shellspec &>/dev/null; then
  echo "✓ shellspec $(shellspec --version 2>&1)"
else
  echo "Installing ShellSpec..."
  curl -fsSL https://git.io/shellspec | sh -s -- --yes
  echo "✓ ShellSpec installed"
fi

# Make scripts executable
chmod +x core/scripts/*.sh 2>/dev/null || true

echo ""
echo "Setup complete. Run 'make test' to execute tests."
