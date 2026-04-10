Describe 'dashboard/src/App.tsx skeleton with 7 placeholder components (Task 3)'
  APP_TSX="dashboard/src/App.tsx"
  COMPONENTS_DIR="dashboard/src/components"
  COMPONENT_NAMES="HeroMetrics BacklogBoard VelocityChart StoryDetail AgentMessages InsightsPanel Sidebar"

  # -- AC1: dashboard/src/App.tsx exists --

  It 'has an App.tsx file under dashboard/src/'
    check_app_tsx_exists() {
      [ -f "$APP_TSX" ] && echo "ok"
    }
    When call check_app_tsx_exists
    The output should equal "ok"
  End

  # -- AC2: 7 component directories exist, each with an index.tsx --

  It 'has all 7 component directories each containing an index.tsx file'
    check_component_directories() {
      missing=""
      for name in $COMPONENT_NAMES; do
        dir="$COMPONENTS_DIR/$name"
        file="$dir/index.tsx"
        if [ ! -d "$dir" ] || [ ! -f "$file" ]; then
          missing="$missing $name"
        fi
      done
      if [ -z "$missing" ]; then
        echo "ok"
      else
        echo "missing:$missing"
      fi
    }
    When call check_component_directories
    The output should equal "ok"
  End

  # -- AC3: Each component's index.tsx contains its own component name as placeholder text --

  It 'renders a placeholder text containing each component name in its index.tsx'
    check_placeholder_text() {
      missing=""
      for name in $COMPONENT_NAMES; do
        file="$COMPONENTS_DIR/$name/index.tsx"
        if [ ! -f "$file" ]; then
          missing="$missing $name(no-file)"
          continue
        fi
        if ! grep -q "$name" "$file"; then
          missing="$missing $name(no-label)"
        fi
      done
      if [ -z "$missing" ]; then
        echo "ok"
      else
        echo "missing:$missing"
      fi
    }
    When call check_placeholder_text
    The output should equal "ok"
  End

  # -- AC4: App.tsx imports and references all 7 components --

  It 'imports and uses all 7 components from App.tsx'
    check_app_imports_components() {
      [ -f "$APP_TSX" ] || { echo "no-app-tsx"; return 0; }
      missing=""
      for name in $COMPONENT_NAMES; do
        if ! grep -q "$name" "$APP_TSX"; then
          missing="$missing $name"
        fi
      done
      if [ -z "$missing" ]; then
        echo "ok"
      else
        echo "missing:$missing"
      fi
    }
    When call check_app_imports_components
    The output should equal "ok"
  End
End
