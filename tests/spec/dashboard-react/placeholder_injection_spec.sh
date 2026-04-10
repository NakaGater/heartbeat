Describe 'dashboard/dist/index.html placeholder injection (Task 5)'
  DIST_HTML="dashboard/dist/index.html"

  # -- AC: Build output must contain all 4 placeholders intact --
  #
  # The generate-dashboard.sh pipeline relies on awk-based substitution of
  # {{BACKLOG_DATA}}, {{STORIES_DATA}}, {{AGENT_COLORS}}, {{INSIGHTS_DATA}}
  # inside the template HTML. Vite's build must preserve these literal
  # placeholder strings (they live inside a non-module <script> tag so that
  # esbuild/minifier does not rewrite them). This test guards that contract.

  It 'contains all 4 placeholders ({{BACKLOG_DATA}}, {{STORIES_DATA}}, {{AGENT_COLORS}}, {{INSIGHTS_DATA}}) in the built HTML'
    check_placeholders_in_dist() {
      [ -f "$DIST_HTML" ] || { echo "no-dist-html"; return 0; }
      missing=""
      for ph in '{{BACKLOG_DATA}}' '{{STORIES_DATA}}' '{{AGENT_COLORS}}' '{{INSIGHTS_DATA}}'; do
        if ! grep -qF "$ph" "$DIST_HTML"; then
          missing="$missing $ph"
        fi
      done
      if [ -z "$missing" ]; then
        echo "ok"
      else
        echo "missing:$missing"
      fi
    }
    When call check_placeholders_in_dist
    The output should equal "ok"
  End
End
