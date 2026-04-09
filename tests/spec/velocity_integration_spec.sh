Describe 'Velocity Chart Integration Test: Real Data Verification via generate-dashboard.sh (Task 5)'

  DASHBOARD_SCRIPT="core/scripts/generate-dashboard.sh"

  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/test-story"

    # 実データを模したbacklog.jsonl: points文字列混在・TZ混在・null含有
    # 週割り当て (UTC基準):
    #   2026-W13: s1(3) + s2(2) = 5
    #   2026-W14: s3(1) + s5(4) = 5   ※s4はpoints=nullで除外
    cat > "$TEST_HEARTBEAT/backlog.jsonl" <<'JSONL'
{"story_id":"s1","status":"done","points":3,"completed":"2026-03-23T10:00:00Z","iteration":null}
{"story_id":"s2","status":"done","points":"2","completed":"2026-03-23T19:00:00+09:00","iteration":null}
{"story_id":"s3","status":"done","points":1,"completed":"2026-03-30T08:00:00Z","iteration":null}
{"story_id":"s4","status":"done","points":null,"completed":"2026-03-30T12:00:00Z","iteration":null}
{"story_id":"s5","status":"done","points":"4","completed":"2026-03-30T23:00:00+09:00","iteration":null}
{"story_id":"s6","status":"in_progress","points":2,"completed":null,"iteration":null}
JSONL

    echo '{"task_id":1,"name":"dummy","status":"done"}' \
      > "$TEST_HEARTBEAT/stories/test-story/tasks.jsonl"
    echo '{"from":"tester","to":"implementer","action":"test","status":"ok","note":"dummy","timestamp":"2026-03-30T10:00:00Z"}' \
      > "$TEST_HEARTBEAT/stories/test-story/board.jsonl"
  }

  cleanup() {
    rm -rf "$TEST_PROJECT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  # AC-10: Velocity Chartが正常にレンダリングされる
  # AC-11: 修正前のデータ（既存backlog.jsonl相当）でVelocityが正しく計算される
  #
  # 検証内容:
  # 1. generate-dashboard.sh で実際にdashboard.htmlが生成される
  # 2. 生成されたHTMLにVelocity Chart用のSVGが含まれる
  # 3. 値ラベルが正しい数値（文字列結合ではない）
  # 4. 平均値が数値として正しい（avg 5.0）
  # 5. ラベルがYYYY-Wnn形式
  check_velocity_integration() {
    command -v node >/dev/null 2>&1 || return 1

    # ダッシュボード生成
    bash "$DASHBOARD_SCRIPT" "$TEST_PROJECT" >/dev/null 2>&1
    [ -f "$TEST_HEARTBEAT/dashboard.html" ] || {
      echo "FAIL: dashboard.htmlが生成されなかった"
      return 1
    }

    # 生成されたHTMLからVelocity Chart部分をnodeで検証
    node -e "
      var fs = require('fs');
      var html = fs.readFileSync('$TEST_HEARTBEAT/dashboard.html', 'utf8');

      // BACKLOG_DATAの埋め込みを確認
      if (html.indexOf('BACKLOG_DATA') === -1) {
        console.error('FAIL: BACKLOG_DATAが埋め込まれていない');
        process.exit(1);
      }

      // renderVelocity関数を含むJSを抽出して実行
      // 簡易DOMモックでSVG出力をキャプチャ
      var _innerHTML = '';
      var document = {
        getElementById: function() {
          return {
            set innerHTML(v) { _innerHTML = v; },
            get innerHTML() { return _innerHTML; }
          };
        }
      };

      // HTMLからBACKLOG_DATAとJS関数を抽出して実行
      var dataMatch = html.match(/(?:var|const|let) BACKLOG_DATA = (\[[\s\S]*?\]);/);
      if (!dataMatch) {
        console.error('FAIL: BACKLOG_DATAの抽出に失敗');
        process.exit(1);
      }
      var BACKLOG_DATA = JSON.parse(dataMatch[1]);

      // getISOWeekNumber と renderVelocity を抽出
      var fnMatch = html.match(/function getISOWeekNumber[\s\S]*?function renderVelocity[\s\S]*?el\.innerHTML = svg;\s*\}/);
      if (!fnMatch) {
        console.error('FAIL: renderVelocity関数の抽出に失敗');
        process.exit(1);
      }

      // 関数を実行
      eval(fnMatch[0]);
      renderVelocity();

      var errors = [];

      // --- 検証1: SVGが生成されていること ---
      if (_innerHTML.indexOf('<svg') === -1) {
        errors.push('FAIL: SVGが生成されていない: ' + _innerHTML.substring(0, 100));
      }

      // --- 検証2: 値ラベルが正しい数値であること ---
      // 文字列結合バグの場合 '02' や '014' のような不正な値が出る
      var valuePattern = />(\d+)<\/text>/g;
      var valueMatches = [];
      var m;
      while ((m = valuePattern.exec(_innerHTML)) !== null) {
        valueMatches.push(m[1]);
      }

      // W13=5, W14=5 の値ラベルが存在すること
      var found5count = valueMatches.filter(function(v) { return v === '5'; }).length;
      if (found5count < 2) {
        errors.push('FAIL: 値ラベル5が2つ期待されるが ' + found5count + ' 個。実際の値: ' + valueMatches.join(', '));
      }

      // 文字列結合の典型パターンがないこと
      var badPatterns = ['02', '014', '032', '0320', '21', '14'];
      valueMatches.forEach(function(v) {
        if (badPatterns.indexOf(v) !== -1 && v !== '5') {
          errors.push('FAIL: 文字列結合の疑い: 値 \"' + v + '\" が検出された');
        }
      });

      // --- 検証3: 平均値が正しいこと ---
      // (5 + 5) / 2 = 5.0
      var avgMatch = _innerHTML.match(/avg (\d+\.?\d*)/);
      if (!avgMatch) {
        errors.push('FAIL: 平均値ラベルが見つからない');
      } else {
        var avgVal = parseFloat(avgMatch[1]);
        if (avgVal !== 5.0) {
          errors.push('FAIL: 平均値が 5.0 でない。実際: ' + avgVal);
        }
      }

      // --- 検証4: ラベルがYYYY-Wnn形式であること ---
      var labelPattern = /text-anchor=\"middle\" font-size=\"10\" fill=\"var\(--text-muted\)\">([^<]+)</g;
      var labels = [];
      while ((m = labelPattern.exec(_innerHTML)) !== null) {
        labels.push(m[1]);
      }
      if (labels.length === 0) {
        errors.push('FAIL: X軸ラベルが見つからない');
      } else {
        labels.forEach(function(lbl) {
          if (!/^\d{4}-W\d{2}$/.test(lbl)) {
            errors.push('FAIL: ラベル \"' + lbl + '\" がYYYY-Wnn形式でない');
          }
        });
      }

      if (errors.length > 0) {
        errors.forEach(function(e) { console.error(e); });
        process.exit(1);
      }
      console.log('OK: Velocity統合テスト全検証パス — ラベル: ' + labels.join(', ') + ', 値: ' + valueMatches.join(', ') + ', 平均: ' + avgMatch[1]);
      process.exit(0);
    " 2>&1
    return $?
  }

  It 'displays correct numerical values in Velocity Chart of generated HTML'
    When call check_velocity_integration
    The status should be success
    The output should not include 'FAIL'
  End
End
