PLUGIN_JSON=".github/plugin/plugin.json"

check_author_name_is_nakag() {
  jq -e '.author.name == "NakaG"' "$PLUGIN_JSON" >/dev/null 2>&1
}

check_publisher_absent() {
  ! jq -e '.publisher' "$PLUGIN_JSON" >/dev/null 2>&1
}

Describe 'Copilot plugin.json author field'
  It 'has author.name equal to NakaG'
    When call check_author_name_is_nakag
    The status should be success
  End

  It 'publisher key does not exist'
    When call check_publisher_absent
    The status should be success
  End
End
