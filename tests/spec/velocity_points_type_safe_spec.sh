Describe 'renderVelocity(): Points Type Safety and Null Guard (Task 2)'

  DASHBOARD="core/templates/dashboard.html"

  extract_dashboard_functions() {
    local helper render
    helper=$(sed -n '/function getISOWeekNumber/,/^  }/p' "$DASHBOARD")
    render=$(sed -n '/function renderVelocity/,/^  }/p' "$DASHBOARD")
    [ -z "$helper" ] && return 1
    [ -z "$render" ] && return 1
    DASHBOARD_HELPER="$helper"
    DASHBOARD_RENDER="$render"
    return 0
  }

  # AC-1, AC-11, AC-12: Correct numeric addition when points are mixed string/null/0
  # Expected: "3"(string) + 2(number) = 5(number), null excluded, 0 added as 0
  # Current bug: (0 + "3") => "03" (string concat), then + 2 => "032"
  check_velocity_points_type_coercion() {
    command -v node >/dev/null 2>&1 || return 1
    extract_dashboard_functions || return 1
    node -e "
      var _innerHTML = '';
      var document = {
        getElementById: function() {
          return { set innerHTML(v) { _innerHTML = v; }, get innerHTML() { return _innerHTML; } };
        }
      };
      var BACKLOG_DATA = [
        { story_id: 's1', iteration: null, status: 'done', points: '3', completed: '2026-01-05' },
        { story_id: 's2', iteration: null, status: 'done', points: 2,   completed: '2026-01-05' },
        { story_id: 's3', iteration: null, status: 'done', points: null, completed: '2026-01-05' },
        { story_id: 's4', iteration: null, status: 'done', points: 0,   completed: '2026-01-05' }
      ];
      ${DASHBOARD_HELPER}
      ${DASHBOARD_RENDER}
      renderVelocity();
      // s1(\"3\") + s2(2) + s4(0) = 5, s3(null)は除外される
      // 棒グラフの値ラベルで確認: SVG内に数値 5 が表示されること
      // 現状バグでは文字列結合 '032' + 0 => '0320' となる
      var valueMatch = _innerHTML.match(/>(\d+)<\/text>/g);
      if (!valueMatch) {
        console.error('FAIL: 棒グラフの値ラベルが見つからない');
        process.exit(1);
      }
      // 値ラベルからテキスト抽出
      var vals = valueMatch.map(function(m) { return m.replace(/>/, '').replace(/<\/text>/, ''); });
      // 数値5が含まれていること（文字列結合の結果 '032' や '0320' でないこと）
      if (vals.indexOf('5') === -1) {
        console.error('FAIL: 期待値 5 が見つからない。実際の値ラベル: ' + vals.join(', '));
        process.exit(1);
      }
      process.exit(0);
    " 2>&1
    return $?
  }

  It 'performs numeric addition and displays correct total with mixed string, null, and 0 points'
    When call check_velocity_points_type_coercion
    The status should be success
    The output should not include 'FAIL'
  End
End
