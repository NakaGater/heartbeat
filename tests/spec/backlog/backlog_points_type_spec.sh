Describe 'backlog.jsonl Points Field Type Validation'
  Describe 'Points Type Safety'
    It 'verifies that all points fields are number type or null'
      check_points_type() {
        local file=".heartbeat/backlog.jsonl"
        local line_num=0
        local errors=0
        while IFS= read -r line || [ -n "$line" ]; do
          line_num=$((line_num + 1))
          [ -z "$line" ] && continue
          # jq type returns "number", "string", "null", etc.
          local pt_type
          pt_type=$(echo "$line" | jq -r '.points | type' 2>/dev/null)
          if [ "$pt_type" != "number" ] && [ "$pt_type" != "null" ]; then
            local sid
            sid=$(echo "$line" | jq -r '.story_id // "unknown"' 2>/dev/null)
            echo "ERROR line $line_num (story $sid): points type is '$pt_type', expected number or null"
            errors=$((errors + 1))
          fi
        done < "$file"
        return $errors
      }
      When call check_points_type
      The status should be success
      The output should not include 'ERROR'
    End
  End
End
