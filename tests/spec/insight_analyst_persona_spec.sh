Describe 'insight-analyst エージェントペルソナ定義'
  # ペルソナファイルのパス（.yaml または .md）
  PERSONA_YAML="core/agent-personas/insight-analyst.yaml"
  PERSONA_MD="core/agent-personas/insight-analyst.md"

  resolve_persona_file() {
    if [ -f "$PERSONA_YAML" ]; then
      echo "$PERSONA_YAML"
    elif [ -f "$PERSONA_MD" ]; then
      echo "$PERSONA_MD"
    else
      echo ""
    fi
  }

  It 'insight-analyst ペルソナファイルが存在すること'
    When call resolve_persona_file
    The output should not equal ""
  End

  It '必須フィールド name が定義されていること'
    Skip if "ペルソナファイルが存在しない" [ -z "$(resolve_persona_file)" ]
    file=$(resolve_persona_file)
    When run grep -iq 'name' "$file"
    The status should be success
  End

  It '必須フィールド role が定義されていること'
    Skip if "ペルソナファイルが存在しない" [ -z "$(resolve_persona_file)" ]
    file=$(resolve_persona_file)
    When run grep -iq 'role' "$file"
    The status should be success
  End

  It '必須フィールド responsibilities が定義されていること'
    Skip if "ペルソナファイルが存在しない" [ -z "$(resolve_persona_file)" ]
    file=$(resolve_persona_file)
    When run grep -iq 'responsibilit' "$file"
    The status should be success
  End

  It '必須フィールド workflow が定義されていること'
    Skip if "ペルソナファイルが存在しない" [ -z "$(resolve_persona_file)" ]
    file=$(resolve_persona_file)
    When run grep -iq 'workflow' "$file"
    The status should be success
  End

  It '必須フィールド inputs が定義されていること'
    Skip if "ペルソナファイルが存在しない" [ -z "$(resolve_persona_file)" ]
    file=$(resolve_persona_file)
    When run grep -iq 'inputs\|input' "$file"
    The status should be success
  End

  It '必須フィールド outputs が定義されていること'
    Skip if "ペルソナファイルが存在しない" [ -z "$(resolve_persona_file)" ]
    file=$(resolve_persona_file)
    When run grep -iq 'outputs\|output' "$file"
    The status should be success
  End

  It '既存エージェントとの名前衝突がないこと'
    # insight-analyst という名前が既存ペルソナに使われていないことを確認
    check_no_collision() {
      for agent in core/agent-personas/*.md core/agent-personas/*.yaml; do
        [ -f "$agent" ] || continue
        case "$agent" in
          *insight-analyst*) continue ;;
        esac
        grep -qi 'insight.analyst' "$agent" && return 1
      done
      return 0
    }
    When call check_no_collision
    The status should be success
  End
End
