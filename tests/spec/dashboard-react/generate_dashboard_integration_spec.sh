Describe 'generate-dashboard.sh integration with Vite dist (Task 5)'
  SCRIPT="core/scripts/generate-dashboard.sh"
  DIST_HTML="dashboard/dist/index.html"

  # -- AC (Task 5, conditions 1 & 3) --
  #
  # Condition 1: generate-dashboard.sh must reference dashboard/dist/index.html
  #              as its TEMPLATE source (the Vite build output), NOT the old
  #              core/templates/dashboard.html.
  # Condition 3: After running generate-dashboard.sh, the resulting
  #              .heartbeat/dashboard.html must contain zero remaining
  #              {{...}} placeholders AND must include the React root marker
  #              (id="root") proving it was generated from the Vite dist.
  #
  # This test runs the pipeline end-to-end against a temporary PROJECT_ROOT
  # and asserts both the React marker presence and the absence of all four
  # placeholders in the produced dashboard.html.

  It 'produces .heartbeat/dashboard.html from the Vite dist with all placeholders replaced and React root marker present'
    run_pipeline_and_check() {
      [ -f "$DIST_HTML" ] || { echo "no-dist-html"; return 0; }
      tmp_root="$(mktemp -d)"
      mkdir -p "$tmp_root/.heartbeat/stories" "$tmp_root/.heartbeat/insights"
      : > "$tmp_root/.heartbeat/backlog.jsonl"
      : > "$tmp_root/.heartbeat/insights/raw.jsonl"
      : > "$tmp_root/.heartbeat/insights/findings.jsonl"
      : > "$tmp_root/.heartbeat/insights/insights.jsonl"
      : > "$tmp_root/.heartbeat/insights/opportunities.jsonl"

      bash "$SCRIPT" "$tmp_root" >/dev/null 2>&1 || { echo "script-failed"; rm -rf "$tmp_root"; return 0; }

      out="$tmp_root/.heartbeat/dashboard.html"
      [ -f "$out" ] || { echo "no-output"; rm -rf "$tmp_root"; return 0; }

      # Must contain the React root marker from the Vite build
      if ! grep -qF 'id="root"' "$out"; then
        echo "missing-react-root"
        rm -rf "$tmp_root"
        return 0
      fi

      # Must NOT contain any of the 4 placeholders
      remaining=""
      for ph in '{{BACKLOG_DATA}}' '{{STORIES_DATA}}' '{{AGENT_COLORS}}' '{{INSIGHTS_DATA}}'; do
        if grep -qF "$ph" "$out"; then
          remaining="$remaining $ph"
        fi
      done
      rm -rf "$tmp_root"

      if [ -n "$remaining" ]; then
        echo "placeholders-remain:$remaining"
      else
        echo "ok"
      fi
    }
    When call run_pipeline_and_check
    The output should equal "ok"
  End
End
