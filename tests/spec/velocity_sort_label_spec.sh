Describe 'Velocity Chart Sort and Label Display With YYYY-Wnn Format (Task 4)'

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

  # AC-9: X-axis labels should be displayed in "YYYY-Wnn" format
  # AC-10: Weeks should be sorted in chronological order
  #
  # Verification: Intentionally reverse the order of input completed dates,
  # and confirm labels appear in ascending (chronological) order in SVG output.
  check_sort_and_label_format() {
    command -v node >/dev/null 2>&1 || return 1
    extract_dashboard_functions || return 1
    node -e "
      var _innerHTML = '';
      var document = {
        getElementById: function() {
          return { set innerHTML(v) { _innerHTML = v; }, get innerHTML() { return _innerHTML; } };
        }
      };
      // 意図的に逆順: W14, W12, W08, W01
      var BACKLOG_DATA = [
        { story_id: 's1', iteration: null, status: 'done', points: 2, completed: '2026-04-02T10:00:00Z' },
        { story_id: 's2', iteration: null, status: 'done', points: 3, completed: '2026-03-16T10:00:00Z' },
        { story_id: 's3', iteration: null, status: 'done', points: 1, completed: '2026-02-20T10:00:00Z' },
        { story_id: 's4', iteration: null, status: 'done', points: 5, completed: '2026-01-02T10:00:00Z' },
        { story_id: 's5', iteration: null, status: 'done', points: 4, completed: '2025-12-29T10:00:00Z' }
      ];
      ${DASHBOARD_HELPER}
      ${DASHBOARD_RENDER}
      renderVelocity();

      var errors = [];

      // --- AC-9: 全ラベルが YYYY-Wnn 形式であること ---
      var labelPattern = /text-anchor=\"middle\" font-size=\"10\" fill=\"var\(--text-muted\)\">([^<]+)</g;
      var labels = [];
      var m;
      while ((m = labelPattern.exec(_innerHTML)) !== null) {
        labels.push(m[1]);
      }
      if (labels.length === 0) {
        errors.push('AC-9 FAIL: X軸ラベルが見つからない');
      } else {
        labels.forEach(function(lbl) {
          if (!/^\d{4}-W\d{2}$/.test(lbl)) {
            errors.push('AC-9 FAIL: ラベル \"' + lbl + '\" が YYYY-Wnn 形式でない');
          }
        });
      }

      // --- AC-10: ラベルが時系列順（昇順）に並んでいること ---
      if (labels.length >= 2) {
        for (var i = 1; i < labels.length; i++) {
          if (labels[i] <= labels[i - 1]) {
            errors.push('AC-10 FAIL: ラベルが時系列順でない: \"' + labels[i - 1] + '\" の後に \"' + labels[i] + '\"');
          }
        }
      }

      // --- 年跨ぎの確認: 2025-W01 と 2026-Wxx が正しく混在ソートされること ---
      if (labels.length > 0 && labels[0].indexOf('2025') === -1 && labels[0].indexOf('2026') === -1) {
        errors.push('AC-10 FAIL: 年情報が含まれるべきだが: \"' + labels[0] + '\"');
      }

      if (errors.length > 0) {
        errors.forEach(function(e) { console.error(e); });
        process.exit(1);
      }
      console.log('OK: AC-9 (YYYY-Wnn形式ラベル) と AC-10 (時系列順ソート) パス — ラベル: ' + labels.join(', '));
      process.exit(0);
    " 2>&1
    return $?
  }

  It 'displays X-axis labels in YYYY-Wnn format in chronological order (correctly sorts reverse-ordered input)'
    When call check_sort_and_label_format
    The status should be success
    The output should not include 'FAIL'
  End
End
