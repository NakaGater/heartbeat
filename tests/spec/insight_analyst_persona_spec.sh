Describe 'insight-analyst Agent Persona Definition'
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

  It 'verifies that the insight-analyst persona file exists'
    When call resolve_persona_file
    The output should not equal ""
  End

  It 'defines the required field name'
    Skip if "persona file does not exist" [ -z "$(resolve_persona_file)" ]
    file=$(resolve_persona_file)
    When run grep -iq 'name' "$file"
    The status should be success
  End

  It 'defines the required field role'
    Skip if "persona file does not exist" [ -z "$(resolve_persona_file)" ]
    file=$(resolve_persona_file)
    When run grep -iq 'role' "$file"
    The status should be success
  End

  It 'defines the required field responsibilities'
    Skip if "persona file does not exist" [ -z "$(resolve_persona_file)" ]
    file=$(resolve_persona_file)
    When run grep -iq 'responsibilit' "$file"
    The status should be success
  End

  It 'defines the required field workflow'
    Skip if "persona file does not exist" [ -z "$(resolve_persona_file)" ]
    file=$(resolve_persona_file)
    When run grep -iq 'workflow' "$file"
    The status should be success
  End

  It 'defines the required field inputs'
    Skip if "persona file does not exist" [ -z "$(resolve_persona_file)" ]
    file=$(resolve_persona_file)
    When run grep -iq 'inputs\|input' "$file"
    The status should be success
  End

  It 'defines the required field outputs'
    Skip if "persona file does not exist" [ -z "$(resolve_persona_file)" ]
    file=$(resolve_persona_file)
    When run grep -iq 'outputs\|output' "$file"
    The status should be success
  End

  It 'has no name collision with existing agents'
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
