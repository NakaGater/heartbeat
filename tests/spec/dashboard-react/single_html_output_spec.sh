Describe 'dashboard/dist/index.html single-file output (Task 4)'
  DIST_DIR="dashboard/dist"
  DIST_HTML="dashboard/dist/index.html"

  # -- AC1: dashboard/dist/ contains only index.html (single-file output) --

  It 'produces exactly one file (index.html) in dashboard/dist/'
    check_single_file_output() {
      [ -d "$DIST_DIR" ] || { echo "no-dist-dir"; return 0; }
      # Count regular files under dist/ (recursively, excluding dotfiles)
      count=$(find "$DIST_DIR" -type f ! -name '.*' | wc -l | tr -d ' ')
      if [ "$count" = "1" ] && [ -f "$DIST_HTML" ]; then
        echo "ok"
      else
        echo "unexpected-file-count:$count"
      fi
    }
    When call check_single_file_output
    The output should equal "ok"
  End

  # -- AC2: Contains inline <script> (no external .js src= in same dir) --

  It 'contains an inline <script> tag with no external src referencing local .js files'
    check_inline_script() {
      [ -f "$DIST_HTML" ] || { echo "no-dist-html"; return 0; }
      # Must contain at least one <script> tag
      if ! grep -q '<script' "$DIST_HTML"; then
        echo "no-script-tag"
        return 0
      fi
      # Must NOT contain <script ... src="..."> referencing a .js file
      # (external CDN URLs would also count as external, but we mainly care about local bundle refs)
      if grep -Eq '<script[^>]+src=["'"'"'][^"'"'"']*\.js' "$DIST_HTML"; then
        echo "has-external-script-src"
        return 0
      fi
      echo "ok"
    }
    When call check_inline_script
    The output should equal "ok"
  End

  # -- AC3: Contains inline <style> (no external <link rel="stylesheet">) --

  It 'contains an inline <style> tag with no external stylesheet <link>'
    check_inline_style() {
      [ -f "$DIST_HTML" ] || { echo "no-dist-html"; return 0; }
      if ! grep -q '<style' "$DIST_HTML"; then
        echo "no-style-tag"
        return 0
      fi
      if grep -Eq '<link[^>]+rel=["'"'"']stylesheet' "$DIST_HTML"; then
        echo "has-external-stylesheet-link"
        return 0
      fi
      echo "ok"
    }
    When call check_inline_style
    The output should equal "ok"
  End

  # AC4 (placeholder names check) removed in 0059c: after 0059b replaced
  # Placeholder stubs with real React components, the Vite production build
  # minifies/mangles component names, so grepping for "HeroMetrics" etc.
  # against the built HTML became meaningless. Vitest component tests
  # (dashboard/src/components/*/*.test.tsx) now cover component rendering.
End
