DASHBOARD="core/templates/dashboard.html"

# Task 3 completion condition 1:
# フォールバック時、X軸ラベルが "Week N" 形式で表示される
# (SVG出力をnodeで実行して検証)
check_week_labels_in_svg_output() {
  command -v node >/dev/null 2>&1 || return 1

  local helper
  helper=$(sed -n '/function getISOWeekNumber/,/^  }/p' "$DASHBOARD")
  [ -z "$helper" ] && return 1

  local render
  render=$(sed -n '/function renderVelocity/,/^  }/p' "$DASHBOARD")
  [ -z "$render" ] && return 1

  # node でフォールバックデータを与えて SVG 出力を検証
  node -e "
    var _innerHTML = '';
    var document = {
      getElementById: function() {
        return { set innerHTML(v) { _innerHTML = v; }, get innerHTML() { return _innerHTML; } };
      }
    };
    var BACKLOG_DATA = [
      { story_id: 's1', iteration: null, status: 'done', points: 3, completed: '2026-01-05' },
      { story_id: 's2', iteration: null, status: 'done', points: 5, completed: '2026-01-12' },
      { story_id: 's3', iteration: null, status: 'done', points: 2, completed: '2026-01-05' }
    ];
    ${helper}
    ${render}
    renderVelocity();
    // Week ラベルが SVG 出力に含まれることを検証
    var weekMatches = _innerHTML.match(/Week \d+/g);
    if (!weekMatches || weekMatches.length < 2) {
      console.error('FAIL: Expected at least 2 Week labels, got ' + (weekMatches ? weekMatches.length : 0));
      process.exit(1);
    }
    process.exit(0);
  " 2>&1
  return $?
}

# Task 3 completion condition 2:
# フォールバック時、平均ベロシティ線がフォールバックデータの平均値で描画される
check_avg_line_in_svg_output() {
  command -v node >/dev/null 2>&1 || return 1

  local helper
  helper=$(sed -n '/function getISOWeekNumber/,/^  }/p' "$DASHBOARD")
  [ -z "$helper" ] && return 1

  local render
  render=$(sed -n '/function renderVelocity/,/^  }/p' "$DASHBOARD")
  [ -z "$render" ] && return 1

  node -e "
    var _innerHTML = '';
    var document = {
      getElementById: function() {
        return { set innerHTML(v) { _innerHTML = v; }, get innerHTML() { return _innerHTML; } };
      }
    };
    var BACKLOG_DATA = [
      { story_id: 's1', iteration: null, status: 'done', points: 3, completed: '2026-01-05' },
      { story_id: 's2', iteration: null, status: 'done', points: 5, completed: '2026-01-12' }
    ];
    ${helper}
    ${render}
    renderVelocity();
    // stroke-dasharray による平均線の存在を検証
    if (!_innerHTML.match(/stroke-dasharray/)) {
      console.error('FAIL: stroke-dasharray not found');
      process.exit(1);
    }
    // avg ラベルと正しい平均値 (3+5)/2=4.0
    if (!_innerHTML.match(/avg 4\.0/)) {
      console.error('FAIL: avg 4.0 label not found');
      process.exit(1);
    }
    process.exit(0);
  " 2>&1
  return $?
}

# Task 3 design decision:
# SVG描画コードを汎化し、iteration別と週番号別で重複しないこと
# (renderVelocity内の '<svg viewBox' 出現が1回のみ = 統合済み)
check_svg_rendering_unified() {
  local body
  body=$(sed -n '/function renderVelocity/,/^  }/p' "$DASHBOARD")
  [ -z "$body" ] && return 1

  local count
  count=$(echo "$body" | grep -c '<svg viewBox')
  # 汎化後は1箇所のみであるべき（現在は2箇所に重複）
  [ "$count" -eq 1 ] || return 1
}

Describe 'renderVelocity() フォールバック時の週番号ラベルと平均線'
  It 'フォールバック時に X軸ラベルが Week N 形式で表示される'
    When call check_week_labels_in_svg_output
    The status should be success
  End

  It 'フォールバック時に平均ベロシティ線が正しい平均値で描画される'
    When call check_avg_line_in_svg_output
    The status should be success
  End

  It 'SVG描画コードが iteration/week 共通で汎化されている'
    When call check_svg_rendering_unified
    The status should be success
  End
End
