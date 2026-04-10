Describe 'dashboard/src/styles/tokens.css: CSS design system extraction (Task 2)'
  TOKENS_CSS="dashboard/src/styles/tokens.css"

  # -- AC1: dashboard/src/styles/tokens.css exists --

  It 'has a tokens.css file under dashboard/src/styles/'
    check_tokens_css_exists() {
      [ -f "$TOKENS_CSS" ] && echo "ok"
    }
    When call check_tokens_css_exists
    The output should equal "ok"
  End

  # -- AC2: :root block declares at least 50 CSS custom properties --

  It 'declares at least 50 CSS custom properties inside a :root block'
    check_custom_property_count() {
      [ -f "$TOKENS_CSS" ] || { echo "missing"; return 0; }
      # Extract content of the first :root { ... } block and count `--name:` declarations.
      count=$(awk '
        /:root[[:space:]]*\{/ { inside=1; next }
        inside && /\}/ { inside=0 }
        inside { print }
      ' "$TOKENS_CSS" | grep -Eo -- '--[A-Za-z0-9_-]+[[:space:]]*:' | wc -l | tr -d ' ')
      if [ "${count:-0}" -ge 50 ]; then
        echo "ok"
      else
        echo "only_${count}"
      fi
    }
    When call check_custom_property_count
    The output should equal "ok"
  End
End
