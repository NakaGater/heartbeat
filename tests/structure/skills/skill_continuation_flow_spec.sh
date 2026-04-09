# Verify Continuation Flow section is correctly defined in SKILL.md

SKILL_MD="adapters/claude-code/skills/heartbeat/SKILL.md"

check_continuation_section_exists() {
  grep -q "## Continuation" "$SKILL_MD"
}

check_continuation_after_post_completion() {
  # Get line number of Post-Completion Flow
  post_line=$(grep -n "## Post-Completion Flow" "$SKILL_MD" | head -1 | cut -d: -f1)
  # Get line number of Continuation section
  cont_line=$(grep -n "## Continuation" "$SKILL_MD" | head -1 | cut -d: -f1)
  # Both must exist and Continuation must come after Post-Completion Flow
  [ -n "$post_line" ] && [ -n "$cont_line" ] && [ "$cont_line" -gt "$post_line" ]
}

check_continuation_has_choices() {
  # AskUserQuestion pattern with choice definitions must exist
  grep -q "次のストーリーを実装する" "$SKILL_MD" &&
  grep -q "終了する" "$SKILL_MD"
}

check_continuation_auto_stop_no_ready() {
  # Continuation section must document auto-stop (STOP) when 0 ready stories
  # Extract the section range for verification
  cont_line=$(grep -n "## Continuation" "$SKILL_MD" | head -1 | cut -d: -f1)
  [ -z "$cont_line" ] && return 1
  # Get content from Continuation section to the next ## section
  tail -n +"$cont_line" "$SKILL_MD" | sed -n '2,/^## /p' > /tmp/continuation_section.tmp
  grep -q 'no.*"ready"\|"ready".*exist\|ready.*ない\|No.*ready' /tmp/continuation_section.tmp &&
  grep -q "STOP" /tmp/continuation_section.tmp
}

Describe 'SKILL.md Continuation Flow Section'
  It 'Continuation section exists'
    When call check_continuation_section_exists
    The status should be success
  End

  It 'Continuation section is defined after Post-Completion Flow'
    When call check_continuation_after_post_completion
    The status should be success
  End

  It 'has choice definitions following AskUserQuestion pattern'
    When call check_continuation_has_choices
    The status should be success
  End

  It 'documents auto-stop when no ready stories remain'
    When call check_continuation_auto_stop_no_ready
    The status should be success
  End
End

# --- Task 2: Workflow 2 STOP directive replaced with Continuation Flow call ---

check_wf2_no_stop_directive() {
  # Extract Workflow 2 section (## Workflow 2 to next ## section)
  wf2_start=$(grep -n "## Workflow 2:" "$SKILL_MD" | head -1 | cut -d: -f1)
  [ -z "$wf2_start" ] && return 1
  # Find next ## section line after Workflow 2
  wf2_end=$(tail -n +"$((wf2_start + 1))" "$SKILL_MD" | grep -n "^## " | head -1 | cut -d: -f1)
  [ -z "$wf2_end" ] && return 1
  wf2_end=$((wf2_start + wf2_end))
  # Extract Workflow 2 section content
  sed -n "${wf2_start},${wf2_end}p" "$SKILL_MD" > /tmp/wf2_section.tmp
  # Old STOP directive must not exist
  ! grep -q "STOP: Workflow 2 complete" /tmp/wf2_section.tmp
}

check_wf2_has_continuation_flow_ref() {
  # Workflow 2 section must have a Continuation Flow reference
  wf2_start=$(grep -n "## Workflow 2:" "$SKILL_MD" | head -1 | cut -d: -f1)
  [ -z "$wf2_start" ] && return 1
  wf2_end=$(tail -n +"$((wf2_start + 1))" "$SKILL_MD" | grep -n "^## " | head -1 | cut -d: -f1)
  [ -z "$wf2_end" ] && return 1
  wf2_end=$((wf2_start + wf2_end))
  sed -n "${wf2_start},${wf2_end}p" "$SKILL_MD" > /tmp/wf2_section.tmp
  # Continuation Flow reference must exist
  grep -q "Continuation Flow" /tmp/wf2_section.tmp
}

check_wf2_post_completion_prerequisite() {
  # Workflow 2 section must maintain Post-Completion Flow as a prerequisite
  wf2_start=$(grep -n "## Workflow 2:" "$SKILL_MD" | head -1 | cut -d: -f1)
  [ -z "$wf2_start" ] && return 1
  wf2_end=$(tail -n +"$((wf2_start + 1))" "$SKILL_MD" | grep -n "^## " | head -1 | cut -d: -f1)
  [ -z "$wf2_end" ] && return 1
  wf2_end=$((wf2_start + wf2_end))
  sed -n "${wf2_start},${wf2_end}p" "$SKILL_MD" > /tmp/wf2_section.tmp
  # Post-Completion Flow reference must be maintained
  grep -q "Post-Completion Flow" /tmp/wf2_section.tmp
}

Describe 'SKILL.md Workflow 2 STOP Directive Replacement (Task 2)'
  It 'Workflow 2 has no old STOP directive'
    When call check_wf2_no_stop_directive
    The status should be success
  End

  It 'Workflow 2 has a Continuation Flow reference'
    When call check_wf2_has_continuation_flow_ref
    The status should be success
  End

  It 'Workflow 2 maintains Post-Completion Flow as a prerequisite'
    When call check_wf2_post_completion_prerequisite
    The status should be success
  End
End

# --- Task 3: Workflow 3 STOP directive replaced with Continuation Flow call ---

check_wf3_no_stop_directive() {
  # Extract Workflow 3 section (## Workflow 3 to next ## section)
  wf3_start=$(grep -n "## Workflow 3:" "$SKILL_MD" | head -1 | cut -d: -f1)
  [ -z "$wf3_start" ] && return 1
  # Find next ## section line after Workflow 3
  wf3_end=$(tail -n +"$((wf3_start + 1))" "$SKILL_MD" | grep -n "^## " | head -1 | cut -d: -f1)
  if [ -z "$wf3_end" ]; then
    # If last section, use end of file
    wf3_end=$(wc -l < "$SKILL_MD")
  else
    wf3_end=$((wf3_start + wf3_end))
  fi
  # Extract Workflow 3 section content
  sed -n "${wf3_start},${wf3_end}p" "$SKILL_MD" > /tmp/wf3_section.tmp
  # Old STOP directive must not exist
  ! grep -q "STOP: Workflow 3 complete" /tmp/wf3_section.tmp
}

check_wf3_has_continuation_flow_ref() {
  # Workflow 3 section must have a Continuation Flow reference
  wf3_start=$(grep -n "## Workflow 3:" "$SKILL_MD" | head -1 | cut -d: -f1)
  [ -z "$wf3_start" ] && return 1
  wf3_end=$(tail -n +"$((wf3_start + 1))" "$SKILL_MD" | grep -n "^## " | head -1 | cut -d: -f1)
  if [ -z "$wf3_end" ]; then
    wf3_end=$(wc -l < "$SKILL_MD")
  else
    wf3_end=$((wf3_start + wf3_end))
  fi
  sed -n "${wf3_start},${wf3_end}p" "$SKILL_MD" > /tmp/wf3_section.tmp
  # Continuation Flow reference must exist
  grep -q "Continuation Flow" /tmp/wf3_section.tmp
}

Describe 'SKILL.md Workflow 3 STOP Directive Replacement (Task 3)'
  It 'Workflow 3 has no old STOP directive'
    When call check_wf3_no_stop_directive
    The status should be success
  End

  It 'Workflow 3 has a Continuation Flow reference'
    When call check_wf3_has_continuation_flow_ref
    The status should be success
  End
End

# --- Task 4: Orchestrator responsibilities step 7 update ---

extract_orchestrator_section() {
  # Extract Orchestrator responsibilities section (### Orchestrator responsibilities to next ## section)
  orch_start=$(grep -n "### Orchestrator responsibilities" "$SKILL_MD" | head -1 | cut -d: -f1)
  [ -z "$orch_start" ] && return 1
  orch_end=$(tail -n +"$((orch_start + 1))" "$SKILL_MD" | grep -n "^## " | head -1 | cut -d: -f1)
  if [ -z "$orch_end" ]; then
    orch_end=$(wc -l < "$SKILL_MD")
  else
    orch_end=$((orch_start + orch_end))
  fi
  sed -n "${orch_start},${orch_end}p" "$SKILL_MD" > /tmp/orch_section.tmp
}

check_orch_wf2_continuation_flow() {
  # Workflow 2 stop condition in Orchestrator responsibilities must reference Continuation Flow
  extract_orchestrator_section || return 1
  # "Workflow 2" and "Continuation Flow" must appear in the same context
  grep -i "workflow 2" /tmp/orch_section.tmp | grep -qi "continuation flow"
}

check_orch_wf3_continuation_flow() {
  # Workflow 3 stop condition in Orchestrator responsibilities must reference Continuation Flow
  extract_orchestrator_section || return 1
  grep -i "workflow 3" /tmp/orch_section.tmp | grep -qi "continuation flow"
}

check_orch_wf1_stop_unchanged() {
  # Workflow 1 stop condition in Orchestrator responsibilities must remain STOP
  extract_orchestrator_section || return 1
  grep -i "workflow 1" /tmp/orch_section.tmp | grep -q "STOP"
}

Describe 'SKILL.md Orchestrator Responsibilities Step 7 Update (Task 4)'
  It 'Workflow 2 stop condition references Continuation Flow'
    When call check_orch_wf2_continuation_flow
    The status should be success
  End

  It 'Workflow 3 stop condition references Continuation Flow'
    When call check_orch_wf3_continuation_flow
    The status should be success
  End

  It 'Workflow 1 stop condition remains STOP unchanged'
    When call check_orch_wf1_stop_unchanged
    The status should be success
  End
End
