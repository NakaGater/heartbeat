DASHBOARD="core/templates/dashboard.html"

# Task 1 completion condition 1:
# getISOWeekNumber ヘルパー関数が dashboard.html に定義されている
check_get_iso_week_number_defined() {
  grep -q "function getISOWeekNumber" "$DASHBOARD" || return 1
}

# Task 1 completion condition 2:
# getISOWeekNumber が renderVelocity の直前に配置されている
check_helper_before_render_velocity() {
  # getISOWeekNumber の行番号が renderVelocity の行番号より小さいこと
  local helper_line render_line
  helper_line=$(grep -n "function getISOWeekNumber" "$DASHBOARD" | head -1 | cut -d: -f1)
  render_line=$(grep -n "function renderVelocity" "$DASHBOARD" | head -1 | cut -d: -f1)
  [ -n "$helper_line" ] && [ -n "$render_line" ] && [ "$helper_line" -lt "$render_line" ] || return 1
}

# Task 1 completion condition 3:
# getISOWeekNumber("2026-01-01") が週番号1を返す
check_week_number_jan1() {
  command -v node >/dev/null 2>&1 || return 1
  # dashboard.html から getISOWeekNumber 関数を抽出して node で実行
  local func
  func=$(sed -n '/function getISOWeekNumber/,/^  }/p' "$DASHBOARD")
  [ -z "$func" ] && return 1
  local result
  result=$(node -e "${func}; var r = getISOWeekNumber('2026-01-01'); if (r !== 1) process.exit(1);")
  return $?
}

# Task 1 completion condition 4:
# null/undefined を渡したとき null が返る
check_null_input_returns_null() {
  command -v node >/dev/null 2>&1 || return 1
  local func
  func=$(sed -n '/function getISOWeekNumber/,/^  }/p' "$DASHBOARD")
  [ -z "$func" ] && return 1
  local result
  result=$(node -e "${func}; var r = getISOWeekNumber(null); if (r !== null) process.exit(1);")
  return $?
}

# Task 1 completion condition 5:
# 不正な日付文字列を渡したとき null が返る
check_invalid_date_returns_null() {
  command -v node >/dev/null 2>&1 || return 1
  local func
  func=$(sed -n '/function getISOWeekNumber/,/^  }/p' "$DASHBOARD")
  [ -z "$func" ] && return 1
  local result
  result=$(node -e "${func}; var r = getISOWeekNumber('not-a-date'); if (r !== null) process.exit(1);")
  return $?
}

Describe 'dashboard.html getISOWeekNumber ヘルパー関数'
  It 'getISOWeekNumber 関数が定義されている'
    When call check_get_iso_week_number_defined
    The status should be success
  End

  It 'getISOWeekNumber が renderVelocity の直前に配置されている'
    When call check_helper_before_render_velocity
    The status should be success
  End

  It '"2026-01-01" を渡すと週番号 1 を返す'
    When call check_week_number_jan1
    The status should be success
  End

  It 'null を渡すと null を返す'
    When call check_null_input_returns_null
    The status should be success
  End

  It '不正な日付文字列を渡すと null を返す'
    When call check_invalid_date_returns_null
    The status should be success
  End
End
