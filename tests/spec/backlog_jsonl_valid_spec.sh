Describe 'backlog.jsonl Data Integrity'
  Describe 'JSON Syntax Validation'
    It 'verifies that all lines are valid JSON'
      validate_all_lines() {
        local file=".heartbeat/backlog.jsonl"
        local line_num=0
        local errors=0
        while IFS= read -r line || [ -n "$line" ]; do
          line_num=$((line_num + 1))
          [ -z "$line" ] && continue
          if ! echo "$line" | jq -e '.' > /dev/null 2>&1; then
            echo "INVALID JSON at line $line_num"
            errors=$((errors + 1))
          fi
        done < "$file"
        return $errors
      }
      When call validate_all_lines
      The status should be success
      The output should not include 'INVALID JSON'
    End
  End
End
