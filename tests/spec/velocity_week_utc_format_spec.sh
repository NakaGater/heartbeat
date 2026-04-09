Describe 'getISOWeekNumber(): UTC-based Calculation and YYYY-Wnn Format Return (Task 3)'

  DASHBOARD="core/templates/dashboard.html"

  extract_week_function() {
    local fn
    fn=$(sed -n '/function getISOWeekNumber/,/^  }/p' "$DASHBOARD")
    [ -z "$fn" ] && return 1
    WEEK_FN="$fn"
    return 0
  }

  # AC-7: getISOWeekNumber()が"YYYY-Wnn"形式の文字列を返すこと
  # AC-5: UTCベースで週番号が計算されること
  # AC-6: 同一UTC日のZ表記と+09:00表記が同一週に集計されること
  # AC-8: 年末年始の週番号が正しい年に属すること
  #
  # 現状: 整数(例: 14)を返す。"YYYY-Wnn"形式ではない。
  # 期待: "2026-W14" のような文字列を返す。
  check_week_format_and_utc() {
    command -v node >/dev/null 2>&1 || return 1
    extract_week_function || return 1
    node -e "
      ${WEEK_FN}

      var errors = [];

      // --- AC-7: YYYY-Wnn 形式の文字列を返すこと ---
      var result1 = getISOWeekNumber('2026-03-30T12:00:00Z');
      if (typeof result1 !== 'string' || !/^\d{4}-W\d{2}$/.test(result1)) {
        errors.push('AC-7 FAIL: 期待形式 YYYY-Wnn だが実際は: ' + JSON.stringify(result1) + ' (型: ' + typeof result1 + ')');
      }

      // --- AC-5, AC-7: 既知の日付で正しい週番号を返すこと ---
      // 2026-03-30 (月曜) は ISO week 14
      var result2 = getISOWeekNumber('2026-03-30T00:00:00Z');
      if (result2 !== '2026-W14') {
        errors.push('AC-5 FAIL: 2026-03-30 の週番号は 2026-W14 だが実際は: ' + JSON.stringify(result2));
      }

      // --- AC-6: 同一UTC日のZ表記と+09:00表記が同じ週になること ---
      // 2026-04-01T23:00:00Z と 2026-04-02T08:00:00+09:00 は同じUTC時刻
      var resultZ   = getISOWeekNumber('2026-04-01T23:00:00Z');
      var resultJST = getISOWeekNumber('2026-04-02T08:00:00+09:00');
      if (resultZ !== resultJST) {
        errors.push('AC-6 FAIL: 同一UTC時刻のZ表記(' + resultZ + ')と+09:00表記(' + resultJST + ')が不一致');
      }

      // --- AC-8: 年末年始の週番号がISO年に正しく属すること ---
      // 2025-12-29 (月曜) は ISO week 2026-W01
      var resultYearEnd = getISOWeekNumber('2025-12-29T10:00:00Z');
      if (resultYearEnd !== '2026-W01') {
        errors.push('AC-8 FAIL: 2025-12-29 は ISO 2026-W01 だが実際は: ' + JSON.stringify(resultYearEnd));
      }

      if (errors.length > 0) {
        errors.forEach(function(e) { console.error(e); });
        process.exit(1);
      }
      console.log('OK: 全AC (5,6,7,8) パス');
      process.exit(0);
    " 2>&1
    return $?
  }

  It 'returns YYYY-Wnn format with UTC-based calculation handling mixed timezones and year boundaries'
    When call check_week_format_and_utc
    The status should be success
    The output should not include 'FAIL'
  End
End
