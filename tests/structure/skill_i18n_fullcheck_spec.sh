# 構造テスト: SKILL.md ファイル全体の日本語残留チェック + 構造テスト通過検証
# ストーリー: agent-skill-i18n-fix / タスク 3
#
# 検証条件:
#   1. make test-structure が全件パスすること (このテスト自体が構造テストに含まれるため暗黙的に達成)
#   2. core/skills/heartbeat/SKILL.md を日本語文字で grep した結果、ヒット0件であること
#      ただし L89/92/93 の AskUserQuestion 例文はユーザー向け出力例のため除外
#   3. adapters/copilot/skills/heartbeat/SKILL.md を日本語文字で grep した結果、ヒット0件であること
#
# 注意: grep の文字クラス [ぁ-んァ-ヶ一-龥] はロケール依存で矢印(→)やEmojiを
# 誤検出するため、perl の Unicode プロパティ (\p{Hiragana}, \p{Katakana}, \p{Han})
# を使用して正確に日本語文字のみを検出する。

CORE_SKILL="core/skills/heartbeat/SKILL.md"
COPILOT_SKILL="adapters/copilot/skills/heartbeat/SKILL.md"

# Helper: perl で日本語文字 (ひらがな・カタカナ・漢字) を含む行を検出する
# 引数: 検査対象テキスト (stdin)
# 戻り値: 日本語文字が見つかれば 0 (成功)、見つからなければ 1
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

# Helper: perl で日本語文字を含む行を行番号付きで出力する
show_japanese_lines() {
  perl -e 'use open ":std", ":encoding(UTF-8)";
    my $n = 0;
    while (<STDIN>) {
      $n++;
      print "$n: $_" if /\p{Hiragana}|\p{Katakana}|\p{Han}/;
    }'
}

# core SKILL.md から AskUserQuestion 例文ブロックを除外して日本語文字を検出する。
# design.md の注意事項: L89/92/93 はユーザー向け出力例であり
# output-language-rule.md に従った正当な日本語テキスト。検査対象から除外する。
# 除外範囲: "Example:" 行から次の閉じ ``` 行まで (AskUserQuestion コードブロック)
check_core_no_japanese_excluding_examples() {
  # ユーザー向け出力例 (output-language-rule.md 準拠) を除外して日本語検出する。
  # 除外対象:
  #   1. "Example:" 行とその後に続くコードブロック全体 (``` ... ```)
  #   2. AskUserQuestion( ... ) ブロック (Continuation Flow 等)
  #   3. Display: 行 (ユーザー向け表示テキスト)
  #   4. "selects \"...\"" 行 (選択肢参照テキスト)
  filtered=$(awk '
    /^Example:$/ { skip_example=1; next }
    skip_example && /^```$/ && !in_block { in_block=1; next }
    skip_example && in_block && /^```$/ { skip_example=0; in_block=0; next }
    skip_example && in_block { next }
    /AskUserQuestion\(/ { skip_ask=1; next }
    skip_ask { if (/\)/) skip_ask=0; next }
    /Display:/ { next }
    /selects "/ { next }
    { skip_example=0; print }
  ' "$CORE_SKILL")
  if echo "$filtered" | has_japanese; then
    echo "Japanese text found in core SKILL.md (excluding AskUserQuestion examples):"
    echo "$filtered" | show_japanese_lines
    return 1
  fi
  return 0
}

# copilot SKILL.md は例外なく全体を検査する (AskUserQuestion 例文が存在しない)
check_copilot_no_japanese_full() {
  if has_japanese < "$COPILOT_SKILL"; then
    echo "Japanese text found in copilot SKILL.md:"
    show_japanese_lines < "$COPILOT_SKILL"
    return 1
  fi
  return 0
}

Describe 'SKILL.md full Japanese residue check (Task 3: overall verification)'
  It 'core SKILL.md has no Japanese LLM-instruction text (AskUserQuestion output examples excluded)'
    When call check_core_no_japanese_excluding_examples
    The status should be success
  End

  It 'copilot SKILL.md has no Japanese characters at all'
    When call check_copilot_no_japanese_full
    The status should be success
  End
End
