Describe 'generated dashboard.html exposes window globals as valid JS (regression for 0059a QA finding)'
  SCRIPT="core/scripts/generate-dashboard.sh"
  DIST_HTML="dashboard/dist/index.html"

  # -- Regression context --
  #
  # The original awk placeholder replacement in generate-dashboard.sh substituted
  # every occurrence of {{BACKLOG_DATA}}/{{STORIES_DATA}}/{{AGENT_COLORS}}/
  # {{INSIGHTS_DATA}} in the template, including inside JSON string values
  # embedded via board.jsonl `detail` fields. When such a detail text literally
  # contained one of those tokens, the awk pass expanded a raw JSON object into
  # the middle of a JSON string literal, producing malformed JS ("Unexpected
  # identifier 'pdm'") and leaving window.BACKLOG_DATA / STORIES_DATA /
  # AGENT_COLORS / INSIGHTS_DATA undefined at runtime.
  #
  # This spec seeds a PROJECT_ROOT whose board.jsonl contains exactly that
  # hostile text, runs generate-dashboard.sh, and then uses node to parse the
  # non-module <script> block and verify the 4 window globals are present and
  # structurally valid.

  It 'parses the generated <script> and defines all 4 window globals even when board.jsonl embeds {{...}} tokens'
    check_window_globals() {
      [ -f "$DIST_HTML" ] || { echo "no-dist-html"; return 0; }
      command -v node >/dev/null 2>&1 || { echo "no-node"; return 0; }

      tmp_root="$(mktemp -d)"
      mkdir -p "$tmp_root/.heartbeat/stories/hostile-story" "$tmp_root/.heartbeat/insights"
      : > "$tmp_root/.heartbeat/backlog.jsonl"
      : > "$tmp_root/.heartbeat/insights/raw.jsonl"
      : > "$tmp_root/.heartbeat/insights/findings.jsonl"
      : > "$tmp_root/.heartbeat/insights/insights.jsonl"
      : > "$tmp_root/.heartbeat/insights/opportunities.jsonl"

      # Seed a board.jsonl entry whose detail field embeds all 4 placeholder
      # tokens as literal text. Before the fix, this would break the generated
      # dashboard's JS.
      printf '%s\n' '{"ts":"2026-04-09T00:00:00Z","agent":"tester","action":"regression seed","detail":"hostile text containing {{BACKLOG_DATA}}, {{STORIES_DATA}}, {{AGENT_COLORS}}, {{INSIGHTS_DATA}} literals"}' \
        > "$tmp_root/.heartbeat/stories/hostile-story/board.jsonl"
      : > "$tmp_root/.heartbeat/stories/hostile-story/tasks.jsonl"

      bash "$SCRIPT" "$tmp_root" >/dev/null 2>&1 || { echo "script-failed"; rm -rf "$tmp_root"; return 0; }

      out="$tmp_root/.heartbeat/dashboard.html"
      [ -f "$out" ] || { echo "no-output"; rm -rf "$tmp_root"; return 0; }

      result=$(node -e '
        const fs = require("fs");
        const html = fs.readFileSync(process.argv[1], "utf8");
        const m = html.match(/<script>\s*\n([\s\S]*?)<\/script>/);
        if (!m) { console.log("no-script-block"); process.exit(0); }
        const code = m[1];
        let fn;
        try { fn = new Function("window", code); }
        catch (e) { console.log("js-parse-error:" + e.message); process.exit(0); }
        const w = {};
        try { fn(w); }
        catch (e) { console.log("js-exec-error:" + e.message); process.exit(0); }
        const missing = [];
        for (const k of ["BACKLOG_DATA","STORIES_DATA","AGENT_COLORS","INSIGHTS_DATA"]) {
          if (typeof w[k] === "undefined") missing.push(k);
        }
        if (missing.length) { console.log("missing:" + missing.join(",")); process.exit(0); }
        if (!Array.isArray(w.BACKLOG_DATA)) { console.log("BACKLOG_DATA not array"); process.exit(0); }
        if (!Array.isArray(w.STORIES_DATA)) { console.log("STORIES_DATA not array"); process.exit(0); }
        if (typeof w.AGENT_COLORS !== "object" || w.AGENT_COLORS === null) { console.log("AGENT_COLORS not object"); process.exit(0); }
        if (typeof w.INSIGHTS_DATA !== "object" || w.INSIGHTS_DATA === null) { console.log("INSIGHTS_DATA not object"); process.exit(0); }
        // Verify the hostile literal survived unchanged inside STORIES_DATA
        const found = w.STORIES_DATA.some(s =>
          (s.board || []).some(b => typeof b.detail === "string" && b.detail.indexOf("{{AGENT_COLORS}}") !== -1)
        );
        if (!found) { console.log("hostile-literal-lost"); process.exit(0); }
        console.log("ok");
      ' "$out")

      rm -rf "$tmp_root"
      echo "$result"
    }
    When call check_window_globals
    The output should equal "ok"
  End
End
