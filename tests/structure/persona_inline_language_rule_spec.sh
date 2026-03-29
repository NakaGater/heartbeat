## Test: All persona files reference output-language-rule.md in their
## Output Language section (canonical reference, not inline duplication).

# Helper: extract the Output Language section from a persona file.
# Returns everything between "## Output Language" and the next "##" heading.
extract_output_language_section() {
  persona_file="$1"
  [ -f "$persona_file" ] || return 1
  sed -n '/^## Output Language$/,/^## /{ /^## Output Language$/d; /^## /d; p; }' "$persona_file"
}

# Helper: verify that a persona file's Output Language section contains
# a strict reference to the canonical rule file.
check_output_language_reference() {
  section=$(extract_output_language_section "$1")
  [ -n "$section" ] || return 1

  echo "$section" | grep -q "Follow ../xp/output-language-rule.md strictly" || return 1
}

# Per-persona wrappers (ShellSpec needs named functions for `When call`).
check_pdm()             { check_output_language_reference "core/agent-personas/pdm.md"; }
check_context_manager() { check_output_language_reference "core/agent-personas/context-manager.md"; }
check_designer()        { check_output_language_reference "core/agent-personas/designer.md"; }
check_architect()       { check_output_language_reference "core/agent-personas/architect.md"; }
check_tester()          { check_output_language_reference "core/agent-personas/tester.md"; }
check_implementer()     { check_output_language_reference "core/agent-personas/implementer.md"; }
check_refactor()        { check_output_language_reference "core/agent-personas/refactor.md"; }
check_reviewer()        { check_output_language_reference "core/agent-personas/reviewer.md"; }
check_qa()              { check_output_language_reference "core/agent-personas/qa.md"; }

Describe 'Persona Output Language reference (batch 1)'
  It 'pdm.md references output-language-rule.md'
    When call check_pdm
    The status should be success
  End

  It 'context-manager.md references output-language-rule.md'
    When call check_context_manager
    The status should be success
  End

  It 'designer.md references output-language-rule.md'
    When call check_designer
    The status should be success
  End
End

Describe 'Persona Output Language reference (batch 2)'
  It 'architect.md references output-language-rule.md'
    When call check_architect
    The status should be success
  End

  It 'tester.md references output-language-rule.md'
    When call check_tester
    The status should be success
  End

  It 'implementer.md references output-language-rule.md'
    When call check_implementer
    The status should be success
  End
End

Describe 'Persona Output Language reference (batch 3)'
  It 'refactor.md references output-language-rule.md'
    When call check_refactor
    The status should be success
  End

  It 'reviewer.md references output-language-rule.md'
    When call check_reviewer
    The status should be success
  End

  It 'qa.md references output-language-rule.md'
    When call check_qa
    The status should be success
  End
End

# Cross-persona consistency — all 9 Output Language sections must be identical.
check_all_sections_identical() {
  personas="pdm context-manager designer architect tester implementer refactor reviewer qa"
  reference=""
  for name in $personas; do
    section=$(extract_output_language_section "core/agent-personas/${name}.md")
    [ -n "$section" ] || return 1
    if [ -z "$reference" ]; then
      reference="$section"
    else
      [ "$section" = "$reference" ] || return 1
    fi
  done
}

Describe 'Output Language section cross-persona consistency'
  It 'all 9 persona files have identical Output Language sections'
    When call check_all_sections_identical
    The status should be success
  End
End
