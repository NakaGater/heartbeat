# 構造テスト: SKILL.md の Question Style Guidelines セクションに
# 日本語文字（ひらがな・カタカナ・漢字）が含まれていないことを検証する。
# また、英訳が context.md の意味テーブルと一致していることを確認する。
# ストーリー: agent-skill-i18n-fix / タスク 1

CORE_SKILL="core/skills/heartbeat/SKILL.md"
COPILOT_SKILL="adapters/copilot/skills/heartbeat/SKILL.md"

# Helper: Question Style Guidelines セクションを抽出する
# (セクション見出しから次の ## 見出しまで)
extract_question_style_section() {
  file="$1"
  sed -n '/^## Question Style Guidelines$/,/^## /{ /^## Question Style Guidelines$/d; /^## /d; p; }' "$file"
}

# 日本語文字（ひらがな・カタカナ・漢字）の検出
# grep -P で Unicode プロパティを使用
check_core_no_japanese() {
  section=$(extract_question_style_section "$CORE_SKILL")
  # 日本語文字が見つかったら失敗 (grep が成功 = 日本語あり = テスト失敗)
  if echo "$section" | grep -q '[ぁ-んァ-ヶ一-龥]'; then
    return 1
  fi
  return 0
}

check_copilot_no_japanese() {
  section=$(extract_question_style_section "$COPILOT_SKILL")
  if echo "$section" | grep -q '[ぁ-んァ-ヶ一-龥]'; then
    return 1
  fi
  return 0
}

# 英訳の意味一致チェック: context.md の意味テーブルに基づくキーフレーズが存在すること
# design.md の翻訳マッピングで定義された英訳のキーフレーズを検証する
check_core_english_content() {
  section=$(extract_question_style_section "$CORE_SKILL")
  [ -n "$section" ] || return 1

  # L339: "All questions to users must be presented with choices."
  echo "$section" | grep -qi 'questions.*users.*choices' || return 1
  # L341: "### Principles" (見出し)
  echo "$section" | grep -q '### Principles' || return 1
  # L342: max 5 choices
  echo "$section" | grep -qi 'choices.*5\|5.*choices' || return 1
  # L343: verb-first style
  echo "$section" | grep -qi 'verb.first' || return 1
  # L344: Other (free text) last
  echo "$section" | grep -qi 'other.*free.*text.*last\|last.*option' || return 1
  # L345: output-language-rule.md reference
  echo "$section" | grep -q 'output-language-rule' || return 1
  # L346: two steps (decision first, then reason)
  echo "$section" | grep -qi 'two steps\|2 steps' || return 1
}

check_copilot_english_content() {
  section=$(extract_question_style_section "$COPILOT_SKILL")
  [ -n "$section" ] || return 1

  echo "$section" | grep -qi 'questions.*users.*choices' || return 1
  echo "$section" | grep -q '### Principles' || return 1
  echo "$section" | grep -qi 'choices.*5\|5.*choices' || return 1
  echo "$section" | grep -qi 'verb.first' || return 1
  echo "$section" | grep -qi 'other.*free.*text.*last\|last.*option' || return 1
  echo "$section" | grep -q 'output-language-rule' || return 1
  echo "$section" | grep -qi 'two steps\|2 steps' || return 1
}

Describe 'SKILL.md Question Style Guidelines has no Japanese (core)'
  It 'contains no Japanese characters (hiragana, katakana, kanji) in core SKILL.md'
    When call check_core_no_japanese
    The status should be success
  End

  It 'contains expected English translation key phrases in core SKILL.md'
    When call check_core_english_content
    The status should be success
  End
End

Describe 'SKILL.md Question Style Guidelines has no Japanese (copilot)'
  It 'contains no Japanese characters (hiragana, katakana, kanji) in copilot SKILL.md'
    When call check_copilot_no_japanese
    The status should be success
  End

  It 'contains expected English translation key phrases in copilot SKILL.md'
    When call check_copilot_english_content
    The status should be success
  End
End
