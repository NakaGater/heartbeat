## Test for Task 2 CC1-CC3: pdm.md, context-manager.md, designer.md
## Output Language section has inline rules.
## The three key points that must be present:
##   1. Write output in the same language the user used
##   2. Translate template headings into the user's language
##   3. Keep technical terms in their original language

# Helper: extract the Output Language section from a persona file.
# Returns everything between "## Output Language" and the next "##" heading.
extract_output_language_section() {
  persona_file="$1"
  [ -f "$persona_file" ] || return 1
  sed -n '/^## Output Language$/,/^## /{ /^## Output Language$/d; /^## /d; p; }' "$persona_file"
}

# Helper: verify that a persona file's Output Language section contains
# all three required inline rules.  Accepts the persona file path as $1.
check_inline_output_language_rules() {
  section=$(extract_output_language_section "$1")
  [ -n "$section" ] || return 1

  echo "$section" | grep -q "same language the user used" || return 1
  echo "$section" | grep -q "Translate headings and body text into the user's language" || return 1
  echo "$section" | grep -q "Keep technical terms in their original language" || return 1
}

# Per-persona wrappers (ShellSpec needs named functions for `When call`).
check_pdm()             { check_inline_output_language_rules "core/agent-personas/pdm.md"; }
check_context_manager() { check_inline_output_language_rules "core/agent-personas/context-manager.md"; }
check_designer()        { check_inline_output_language_rules "core/agent-personas/designer.md"; }
check_architect()       { check_inline_output_language_rules "core/agent-personas/architect.md"; }
check_tester()          { check_inline_output_language_rules "core/agent-personas/tester.md"; }
check_implementer()     { check_inline_output_language_rules "core/agent-personas/implementer.md"; }
check_refactor()        { check_inline_output_language_rules "core/agent-personas/refactor.md"; }
check_reviewer()        { check_inline_output_language_rules "core/agent-personas/reviewer.md"; }
check_qa()              { check_inline_output_language_rules "core/agent-personas/qa.md"; }

Describe 'Persona inline language rules (batch 1)'
  It 'when checking pdm.md Output Language section, should contain inline rules for output language, heading translation, and technical term preservation'
    When call check_pdm
    The status should be success
  End

  It 'when checking context-manager.md Output Language section, should contain inline rules for output language, heading translation, and technical term preservation'
    When call check_context_manager
    The status should be success
  End

  It 'when checking designer.md Output Language section, should contain inline rules for output language, heading translation, and technical term preservation'
    When call check_designer
    The status should be success
  End
End

Describe 'Persona inline language rules (batch 2)'
  It 'when checking architect.md Output Language section, should contain inline rules for output language, heading translation, and technical term preservation'
    When call check_architect
    The status should be success
  End

  It 'when checking tester.md Output Language section, should contain inline rules for output language, heading translation, and technical term preservation'
    When call check_tester
    The status should be success
  End

  It 'when checking implementer.md Output Language section, should contain inline rules for output language, heading translation, and technical term preservation'
    When call check_implementer
    The status should be success
  End
End

Describe 'Persona inline language rules (batch 3)'
  It 'when checking refactor.md Output Language section, should contain inline rules for output language, heading translation, and technical term preservation'
    When call check_refactor
    The status should be success
  End

  It 'when checking reviewer.md Output Language section, should contain inline rules for output language, heading translation, and technical term preservation'
    When call check_reviewer
    The status should be success
  End

  It 'when checking qa.md Output Language section, should contain inline rules for output language, heading translation, and technical term preservation'
    When call check_qa
    The status should be success
  End
End

# CC4: Cross-persona consistency — all 9 Output Language sections must be identical.
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
  It 'when comparing all 9 persona files, should have identical Output Language sections'
    When call check_all_sections_identical
    The status should be success
  End
End
