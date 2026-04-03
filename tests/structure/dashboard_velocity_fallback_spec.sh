DASHBOARD="core/templates/dashboard.html"

# Task 2 completion condition 1:
# iters.length === 0 かつ done+points有りストーリーが存在するとき、
# weekMap を構築して getISOWeekNumber で週番号グルーピングする
check_weekmap_fallback_in_render_velocity() {
  # renderVelocity 関数の中身を抽出
  local body
  body=$(sed -n '/function renderVelocity/,/^  }/p' "$DASHBOARD")
  [ -z "$body" ] && return 1

  # weekMap 変数が renderVelocity 内で使われている
  echo "$body" | grep -q "weekMap" || return 1

  # getISOWeekNumber が renderVelocity 内で呼び出されている
  echo "$body" | grep -q "getISOWeekNumber" || return 1
}

Describe 'renderVelocity() フォールバック集計ロジック'
  It 'iters.length===0 のとき weekMap と getISOWeekNumber でフォールバック集計する'
    When call check_weekmap_fallback_in_render_velocity
    The status should be success
  End
End
