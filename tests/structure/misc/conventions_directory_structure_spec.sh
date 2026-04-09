# Verify that tests/CONVENTIONS.md contains directory structure placement rules

CONVENTIONS_FILE="tests/CONVENTIONS.md"

check_directory_structure_section() {
  if ! grep -q '## Directory Structure' "$CONVENTIONS_FILE"; then
    printf "CONVENTIONS.md does not contain a 'Directory Structure' section\n" >&2
    return 1
  fi
}

check_placement_rules() {
  if ! grep -q 'Placement Rules' "$CONVENTIONS_FILE"; then
    printf "CONVENTIONS.md does not contain placement rules\n" >&2
    return 1
  fi
  # Must mention both spec and structure test directories
  if ! grep -q 'tests/spec/' "$CONVENTIONS_FILE"; then
    printf "CONVENTIONS.md does not mention tests/spec/ placement\n" >&2
    return 1
  fi
  if ! grep -q 'tests/structure/' "$CONVENTIONS_FILE"; then
    printf "CONVENTIONS.md does not mention tests/structure/ placement\n" >&2
    return 1
  fi
}

check_subdirectory_naming() {
  if ! grep -qi 'kebab.case\|kebab-case' "$CONVENTIONS_FILE"; then
    printf "CONVENTIONS.md does not mention kebab-case naming convention\n" >&2
    return 1
  fi
}

Describe 'tests/CONVENTIONS.md directory structure guide'
  It 'contains a Directory Structure section'
    When call check_directory_structure_section
    The status should be success
    The stderr should be blank
  End

  It 'contains placement rules for spec and structure tests'
    When call check_placement_rules
    The status should be success
    The stderr should be blank
  End

  It 'documents subdirectory naming convention using kebab-case'
    When call check_subdirectory_naming
    The status should be success
    The stderr should be blank
  End
End
