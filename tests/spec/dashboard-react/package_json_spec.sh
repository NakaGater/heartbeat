Describe 'dashboard/package.json: Vite + React + TypeScript project scaffolding (Task 1)'
  PACKAGE_JSON="dashboard/package.json"

  # -- AC1: dashboard/package.json exists --

  It 'has a package.json file under dashboard/'
    check_package_json_exists() {
      [ -f "$PACKAGE_JSON" ] && echo "ok"
    }
    When call check_package_json_exists
    The output should equal "ok"
  End

  # -- AC2: devDependencies contains vite --

  It 'declares vite in devDependencies'
    check_dev_dep_vite() {
      jq -e '.devDependencies.vite' "$PACKAGE_JSON" >/dev/null && echo "ok"
    }
    When call check_dev_dep_vite
    The output should equal "ok"
  End

  # -- AC3: devDependencies contains react --

  It 'declares react in devDependencies'
    check_dev_dep_react() {
      jq -e '.devDependencies.react' "$PACKAGE_JSON" >/dev/null && echo "ok"
    }
    When call check_dev_dep_react
    The output should equal "ok"
  End

  # -- AC4: devDependencies contains react-dom --

  It 'declares react-dom in devDependencies'
    check_dev_dep_react_dom() {
      jq -e '.devDependencies."react-dom"' "$PACKAGE_JSON" >/dev/null && echo "ok"
    }
    When call check_dev_dep_react_dom
    The output should equal "ok"
  End

  # -- AC5: devDependencies contains typescript --

  It 'declares typescript in devDependencies'
    check_dev_dep_typescript() {
      jq -e '.devDependencies.typescript' "$PACKAGE_JSON" >/dev/null && echo "ok"
    }
    When call check_dev_dep_typescript
    The output should equal "ok"
  End

  # -- AC6: devDependencies contains @types/react --

  It 'declares @types/react in devDependencies'
    check_dev_dep_types_react() {
      jq -e '.devDependencies."@types/react"' "$PACKAGE_JSON" >/dev/null && echo "ok"
    }
    When call check_dev_dep_types_react
    The output should equal "ok"
  End

  # -- AC7: devDependencies contains @types/react-dom --

  It 'declares @types/react-dom in devDependencies'
    check_dev_dep_types_react_dom() {
      jq -e '.devDependencies."@types/react-dom"' "$PACKAGE_JSON" >/dev/null && echo "ok"
    }
    When call check_dev_dep_types_react_dom
    The output should equal "ok"
  End

  # -- AC8: devDependencies contains vite-plugin-singlefile --

  It 'declares vite-plugin-singlefile in devDependencies'
    check_dev_dep_singlefile() {
      jq -e '.devDependencies."vite-plugin-singlefile"' "$PACKAGE_JSON" >/dev/null && echo "ok"
    }
    When call check_dev_dep_singlefile
    The output should equal "ok"
  End
End
