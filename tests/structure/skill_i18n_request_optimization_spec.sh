# 構造テスト: SKILL.md の Copilot-Specific: Request Optimization セクションに
# 日本語文字（ひらがな・カタカナ・漢字）が含まれていないことを検証する。
# また、Rule 1 テーブルの全セルが英語であること、英訳が context.md の意味記述と
# 一致していることを確認する。
# ストーリー: agent-skill-i18n-fix / タスク 2

COPILOT_SKILL="adapters/copilot/skills/heartbeat/SKILL.md"

# Helper: Request Optimization セクションを抽出する
# (セクション見出しから次の ## 見出しまたはファイル末尾まで)
extract_request_optimization_section() {
  sed -n '/^## Copilot-Specific: Request Optimization$/,/^## /{ /^## Copilot-Specific: Request Optimization$/d; /^## /d; p; }' "$COPILOT_SKILL"
}

# Helper: Rule 1 テーブルのみを抽出する
# (テーブルヘッダー行 "|" 始まりの連続行)
extract_rule1_table() {
  section=$(extract_request_optimization_section)
  echo "$section" | sed -n '/^|/,/^[^|]/{/^|/p;}'
}

# Helper: perl で日本語文字 (ひらがな・カタカナ・漢字) を検出する
# grep の文字クラス [ぁ-んァ-ヶ一-龥] はロケール依存で誤検出するため
# perl の Unicode プロパティを使用する (fullcheck と同一手法)
has_japanese() {
  perl -e 'use open ":std", ":encoding(UTF-8)";
    my $found = 0;
    while (<STDIN>) {
      if (/\p{Hiragana}|\p{Katakana}|\p{Han}/) {
        $found = 1;
        last;
      }
    }
    exit($found ? 0 : 1);'
}

# 条件 1: Request Optimization セクション全体に日本語文字が含まれていないこと
check_no_japanese_in_request_optimization() {
  section=$(extract_request_optimization_section)
  if [ -z "$section" ]; then
    # セクションが見つからない場合も失敗
    return 1
  fi
  if echo "$section" | has_japanese; then
    return 1
  fi
  return 0
}

# 条件 2: Rule 1 テーブル内のすべてのセルが英語であること
# テーブルヘッダーが英語化されていることを確認
check_rule1_table_headers_english() {
  table=$(extract_rule1_table)
  if [ -z "$table" ]; then
    return 1
  fi
  header=$(echo "$table" | head -1)
  # 英語ヘッダーが存在すること (design.md の翻訳: 箇所->Interaction Point, 質問タイプ->Question Type, 選択肢->Choices)
  echo "$header" | grep -qi 'Interaction Point' || return 1
  echo "$header" | grep -qi 'Question Type' || return 1
  echo "$header" | grep -qi 'Choices' || return 1
  return 0
}

# 条件 2 (続き): Rule 1 テーブルのデータ行に日本語が含まれていないこと
check_rule1_table_cells_no_japanese() {
  table=$(extract_rule1_table)
  if [ -z "$table" ]; then
    return 1
  fi
  if echo "$table" | has_japanese; then
    return 1
  fi
  return 0
}

# 条件 3: 英訳が context.md の意味記述と一致していること
# design.md の翻訳マッピングから主要キーフレーズを検証する
check_english_content_matches_context() {
  section=$(extract_request_optimization_section)
  [ -n "$section" ] || return 1

  # L379-380: premium request / minimize
  echo "$section" | grep -qi 'premium request' || return 1
  echo "$section" | grep -qi 'minimize' || return 1

  # Rule 1 見出し: vscode_askQuestions for all user interactions
  echo "$section" | grep -q 'vscode_askQuestions' || return 1
  echo "$section" | grep -qi 'all.*user.*interaction\|all.*question.*input' || return 1

  # Rule 1 本文: Never request user input via normal response generation
  echo "$section" | grep -qi 'never.*normal.*response\|never.*user.*input.*normal' || return 1

  # Rule 2: Auto-approve task decomposition / Skip AP2
  echo "$section" | grep -qi 'auto.*approve\|auto-approve' || return 1
  echo "$section" | grep -qi 'skip.*AP2\|AP2.*skip' || return 1
  echo "$section" | grep -qi 'Phase 3' || return 1

  # Rule 3: Consolidate Workflow 3 / do not request additional input
  echo "$section" | grep -qi 'workflow 3\|workflow.*3' || return 1
  echo "$section" | grep -qi 'category.*infer\|auto.*infer.*category\|infer.*category' || return 1
  echo "$section" | grep -q 'vscode_askQuestions' || return 1
}

Describe 'SKILL.md Request Optimization has no Japanese (copilot)'
  It 'contains no Japanese characters in Request Optimization section'
    When call check_no_japanese_in_request_optimization
    The status should be success
  End

  It 'Rule 1 table headers are in English'
    When call check_rule1_table_headers_english
    The status should be success
  End

  It 'Rule 1 table data cells contain no Japanese characters'
    When call check_rule1_table_cells_no_japanese
    The status should be success
  End

  It 'contains expected English translation key phrases matching context.md'
    When call check_english_content_matches_context
    The status should be success
  End
End
