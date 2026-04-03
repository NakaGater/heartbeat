Describe 'auto-commit.sh'
  # Task 1, CC1: テストファイルが存在し ShellSpec で実行可能
  # Task 1, CC2: source 時に副作用なし (main ガード必須)
  # Task 1, CC3: Include で auto-commit.sh を読み込める

  Include ./core/scripts/auto-commit.sh

  Describe 'main guard (CC2)'
    It 'produces no output when sourced'
      When run source ./core/scripts/auto-commit.sh
      The output should equal ""
      The status should be success
    End
  End

  Describe 'Include availability (CC3)'
    It 'makes map_agent_to_type callable after Include'
      When call map_agent_to_type "tester"
      The output should equal "test"
      The status should be success
    End
  End

  Describe 'map_agent_to_type()'
    It 'is defined and callable after source'
      When call map_agent_to_type "tester"
      The output should equal "test"
    End

    # Task 3, CC1: core 3 mappings (tester->test, implementer->feat, refactor->refactor)
    Describe 'core agent type mappings'
      It 'maps tester to test'
        When call map_agent_to_type "tester"
        The output should equal "test"
      End

      It 'maps implementer to feat'
        When call map_agent_to_type "implementer"
        The output should equal "feat"
      End

      It 'maps refactor to refactor'
        When call map_agent_to_type "refactor"
        The output should equal "refactor"
      End
    End

    # Task 3, CC2: architect, pdm, designer, context-manager, reviewer, qa -> chore
    Describe 'non-core agent mappings to chore'
      It 'maps architect to chore'
        When call map_agent_to_type "architect"
        The output should equal "chore"
      End

      It 'maps pdm to chore'
        When call map_agent_to_type "pdm"
        The output should equal "chore"
      End

      It 'maps designer to chore'
        When call map_agent_to_type "designer"
        The output should equal "chore"
      End

      It 'maps context-manager to chore'
        When call map_agent_to_type "context-manager"
        The output should equal "chore"
      End

      It 'maps reviewer to chore'
        When call map_agent_to_type "reviewer"
        The output should equal "chore"
      End

      It 'maps qa to chore'
        When call map_agent_to_type "qa"
        The output should equal "chore"
      End
    End

    # Task 3, CC3: unknown agent name -> chore fallback
    Describe 'unknown agent fallback to chore'
      It 'maps unknown to chore'
        When call map_agent_to_type "unknown"
        The output should equal "chore"
      End

      It 'maps empty string to chore'
        When call map_agent_to_type ""
        The output should equal "chore"
      End

      It 'maps arbitrary string to chore'
        When call map_agent_to_type "nonexistent-agent"
        The output should equal "chore"
      End
    End
  End

  Describe '_find_board_jsonl()'
    Describe 'with explicit story-id'
      setup() {
        TMPDIR_FIND=$(mktemp -d)
        mkdir -p "$TMPDIR_FIND/.heartbeat/stories/target-story"
        echo '{"from":"tester"}' \
          > "$TMPDIR_FIND/.heartbeat/stories/target-story/board.jsonl"
        export CLAUDE_PROJECT_DIR="$TMPDIR_FIND"
      }
      cleanup() {
        rm -rf "$TMPDIR_FIND"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'resolves to the correct per-story board.jsonl'
        When call _find_board_jsonl "target-story"
        The output should end with ".heartbeat/stories/target-story/board.jsonl"
        The status should be success
      End
    End

    Describe 'with nonexistent story-id'
      setup() {
        TMPDIR_FIND2=$(mktemp -d)
        export CLAUDE_PROJECT_DIR="$TMPDIR_FIND2"
      }
      cleanup() {
        rm -rf "$TMPDIR_FIND2"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns empty string for nonexistent story'
        When call _find_board_jsonl "nonexistent"
        The output should equal ""
        The status should be success
      End
    End
  End

  # Task 4, CC1: get_story_scope extracts story ID from board.jsonl path
  Describe 'get_story_scope()'
    Describe 'extracts story ID from board.jsonl directory'
      setup() {
        TMPDIR_T4CC1=$(mktemp -d)
        mkdir -p "$TMPDIR_T4CC1/.heartbeat/stories/my-story"
        echo '{"from":"tester","message":"hello"}' \
          > "$TMPDIR_T4CC1/.heartbeat/stories/my-story/board.jsonl"
        export CLAUDE_PROJECT_DIR="$TMPDIR_T4CC1"
      }
      cleanup() {
        rm -rf "$TMPDIR_T4CC1"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns the story ID from the board.jsonl parent directory name'
        When call get_story_scope
        The output should equal "my-story"
        The status should be success
      End
    End

    # Task 4, CC2: board.jsonl 不在時、scope は空文字列を返す
    Describe 'returns empty string when board.jsonl does not exist'
      setup() {
        TMPDIR_T4CC2=$(mktemp -d)
        export CLAUDE_PROJECT_DIR="$TMPDIR_T4CC2"
      }
      cleanup() {
        rm -rf "$TMPDIR_T4CC2"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns empty string when no board.jsonl exists'
        When call get_story_scope
        The output should equal ""
        The status should be success
      End
    End
  End

  # Task 4, CC3: get_description extracts description from board.jsonl .note
  Describe 'get_description()'
    Describe 'returns note from board.jsonl'
      setup() {
        TMPDIR_T4CC3=$(mktemp -d)
        mkdir -p "$TMPDIR_T4CC3/.heartbeat/stories/auto-commit-fix"
        echo '{"from":"tester","note":"add login test"}' \
          > "$TMPDIR_T4CC3/.heartbeat/stories/auto-commit-fix/board.jsonl"
        export CLAUDE_PROJECT_DIR="$TMPDIR_T4CC3"
      }
      cleanup() {
        rm -rf "$TMPDIR_T4CC3"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'extracts note field from board.jsonl as description'
        When call get_description '{}'
        The output should equal "add login test"
        The status should be success
      End
    End

    # Task 4, CC4: .note 不在時、last_assistant_message の先頭行にフォールバック
    Describe 'falls back to first line of last_assistant_message when note is absent'
      setup() {
        TMPDIR_T4CC4=$(mktemp -d)
        mkdir -p "$TMPDIR_T4CC4/.heartbeat/stories/auto-commit-fix"
        echo '{"from":"tester"}' \
          > "$TMPDIR_T4CC4/.heartbeat/stories/auto-commit-fix/board.jsonl"
        export CLAUDE_PROJECT_DIR="$TMPDIR_T4CC4"
      }
      cleanup() {
        rm -rf "$TMPDIR_T4CC4"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns first line of last_assistant_message when note is missing'
        When call get_description '{"last_assistant_message":"implement login feature\nwith validation"}'
        The output should equal "implement login feature"
        The status should be success
      End
    End

    # Task 4, CC5: すべて不在時、git diff --stat サマリーにフォールバック
    Describe 'falls back to git diff --stat when note and last_assistant_message are both absent'
      setup() {
        TMPDIR_T4CC5=$(mktemp -d)
        # No .heartbeat/stories -> no board.jsonl
        # Initialize a git repo with a staged change for git diff --stat
        git init "$TMPDIR_T4CC5" >/dev/null 2>&1
        echo "initial" > "$TMPDIR_T4CC5/README.md"
        git -C "$TMPDIR_T4CC5" add README.md >/dev/null 2>&1
        git -C "$TMPDIR_T4CC5" \
          -c user.name="test" -c user.email="test@test.com" \
          commit -m "initial" >/dev/null 2>&1
        echo "changed" > "$TMPDIR_T4CC5/README.md"
        git -C "$TMPDIR_T4CC5" add README.md >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_T4CC5"
      }
      cleanup() {
        rm -rf "$TMPDIR_T4CC5"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns non-empty string from git diff --stat when both note and last_assistant_message are absent'
        When call get_description '{}'
        The output should not equal ""
        The status should be success
      End
    End
  End

  # Task 2, CC1: get_agent_name extracts agent_type from stdin JSON
  Describe 'get_agent_name()'
    It 'extracts agent_type from JSON input'
      When call get_agent_name '{"agent_type":"tester"}'
      The output should equal "tester"
      The status should be success
    End

    # Task 2, CC2: agent_type が空/不在の場合、board.jsonl の .from にフォールバック
    # Task 2, CC3: board.jsonl も不在の場合、"unknown" にフォールバックする
    Describe 'fallback to board.jsonl'
      setup() {
        TMPDIR_CC2=$(mktemp -d)
        mkdir -p "$TMPDIR_CC2/.heartbeat/stories/test-story"
        echo '{"from":"designer","message":"done"}' \
          > "$TMPDIR_CC2/.heartbeat/stories/test-story/board.jsonl"
        export CLAUDE_PROJECT_DIR="$TMPDIR_CC2"
      }
      cleanup() {
        rm -rf "$TMPDIR_CC2"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'falls back to board.jsonl .from when agent_type is missing'
        When call get_agent_name '{}'
        The output should equal "designer"
        The status should be success
      End
    End

    # Task 2, CC3: board.jsonl も不在の場合、"unknown" にフォールバックする
    Describe 'fallback to unknown when no board.jsonl'
      setup() {
        TMPDIR_CC3=$(mktemp -d)
        export CLAUDE_PROJECT_DIR="$TMPDIR_CC3"
      }
      cleanup() {
        rm -rf "$TMPDIR_CC3"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns unknown when agent_type is missing and no board.jsonl exists'
        When call get_agent_name '{}'
        The output should equal "unknown"
        The status should be success
      End
    End
  End

  # Task 5, CC1: format_commit_message assembles "<type>(<scope>): <description>"
  Describe 'format_commit_message()'
    It 'assembles type, scope, and description into Conventional Commits format'
      When call format_commit_message "test" "my-story" "add login test"
      The output should equal "test(my-story): add login test"
      The status should be success
    End

    # Task 5, CC2: scope が空の場合、括弧なしの "<type>: <description>" にフォールバック
    It 'falls back to type-colon-description without parentheses when scope is empty'
      When call format_commit_message "chore" "" "update config"
      The output should equal "chore: update config"
      The status should be success
    End
  End

  # Reviewer feedback: _truncate_description() — truncation and trailing period removal
  Describe '_truncate_description()'
    It 'truncates a string longer than 72 chars to 69 chars plus ellipsis'
      # 80-char input: "aaaaa..." (80 x 'a')
      When call _truncate_description "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
      The output should equal "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa..."
      The status should be success
    End

    It 'removes a trailing period from the description'
      When call _truncate_description "add tests."
      The output should equal "add tests"
      The status should be success
    End
  End

  # Story: commit-message-accuracy, Task 1: get_scope_from_diff()
  Describe 'get_scope_from_diff()'
    Describe 'CC1: tests/ only -> scope "tests"'
      setup() {
        TMPDIR_SCOPE1=$(mktemp -d)
        git init "$TMPDIR_SCOPE1" >/dev/null 2>&1
        git -C "$TMPDIR_SCOPE1" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        mkdir -p "$TMPDIR_SCOPE1/tests/spec"
        echo 'test1' > "$TMPDIR_SCOPE1/tests/spec/foo_spec.sh"
        echo 'test2' > "$TMPDIR_SCOPE1/tests/spec/bar_spec.sh"
        git -C "$TMPDIR_SCOPE1" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_SCOPE1"
      }
      cleanup() {
        rm -rf "$TMPDIR_SCOPE1"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns "tests" when only tests/ files are staged'
        When call get_scope_from_diff
        The output should equal "tests"
        The status should be success
      End
    End

    Describe 'CC2: core/scripts/auto-commit.sh only -> scope "auto-commit"'
      setup() {
        TMPDIR_SCOPE2=$(mktemp -d)
        git init "$TMPDIR_SCOPE2" >/dev/null 2>&1
        git -C "$TMPDIR_SCOPE2" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        mkdir -p "$TMPDIR_SCOPE2/core/scripts"
        echo '#!/bin/bash' > "$TMPDIR_SCOPE2/core/scripts/auto-commit.sh"
        git -C "$TMPDIR_SCOPE2" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_SCOPE2"
      }
      cleanup() {
        rm -rf "$TMPDIR_SCOPE2"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns "auto-commit" when only core/scripts/auto-commit.sh is staged'
        When call get_scope_from_diff
        The output should equal "auto-commit"
        The status should be success
      End
    End

    Describe 'CC3: .heartbeat/stories/my-story/ only -> scope "my-story"'
      setup() {
        TMPDIR_SCOPE3=$(mktemp -d)
        git init "$TMPDIR_SCOPE3" >/dev/null 2>&1
        git -C "$TMPDIR_SCOPE3" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        mkdir -p "$TMPDIR_SCOPE3/.heartbeat/stories/my-story"
        echo '{"from":"tester"}' > "$TMPDIR_SCOPE3/.heartbeat/stories/my-story/board.jsonl"
        echo '# tasks' > "$TMPDIR_SCOPE3/.heartbeat/stories/my-story/tasks.md"
        git -C "$TMPDIR_SCOPE3" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_SCOPE3"
      }
      cleanup() {
        rm -rf "$TMPDIR_SCOPE3"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns "my-story" when only .heartbeat/stories/my-story/ files are staged'
        When call get_scope_from_diff
        The output should equal "my-story"
        The status should be success
      End
    End

    Describe 'CC4: adapters/copilot/ only -> scope "copilot"'
      setup() {
        TMPDIR_SCOPE4=$(mktemp -d)
        git init "$TMPDIR_SCOPE4" >/dev/null 2>&1
        git -C "$TMPDIR_SCOPE4" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        mkdir -p "$TMPDIR_SCOPE4/adapters/copilot"
        echo '{}' > "$TMPDIR_SCOPE4/adapters/copilot/plugin.json"
        echo '# copilot' > "$TMPDIR_SCOPE4/adapters/copilot/README.md"
        git -C "$TMPDIR_SCOPE4" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_SCOPE4"
      }
      cleanup() {
        rm -rf "$TMPDIR_SCOPE4"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns "copilot" when only adapters/copilot/ files are staged'
        When call get_scope_from_diff
        The output should equal "copilot"
        The status should be success
      End
    End

    Describe 'CC5: multiple areas -> empty string'
      setup() {
        TMPDIR_SCOPE5=$(mktemp -d)
        git init "$TMPDIR_SCOPE5" >/dev/null 2>&1
        git -C "$TMPDIR_SCOPE5" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        mkdir -p "$TMPDIR_SCOPE5/tests/spec"
        mkdir -p "$TMPDIR_SCOPE5/core/scripts"
        echo 'test1' > "$TMPDIR_SCOPE5/tests/spec/foo_spec.sh"
        echo '#!/bin/bash' > "$TMPDIR_SCOPE5/core/scripts/auto-commit.sh"
        git -C "$TMPDIR_SCOPE5" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_SCOPE5"
      }
      cleanup() {
        rm -rf "$TMPDIR_SCOPE5"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns empty string when files span multiple areas'
        When call get_scope_from_diff
        The output should equal ""
        The status should be success
      End
    End

    Describe 'CC6: single file README.md only -> scope "README"'
      setup() {
        TMPDIR_SCOPE6=$(mktemp -d)
        git init "$TMPDIR_SCOPE6" >/dev/null 2>&1
        git -C "$TMPDIR_SCOPE6" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        echo '# readme' > "$TMPDIR_SCOPE6/README.md"
        git -C "$TMPDIR_SCOPE6" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_SCOPE6"
      }
      cleanup() {
        rm -rf "$TMPDIR_SCOPE6"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns "README" when only README.md is staged'
        When call get_scope_from_diff
        The output should equal "README"
        The status should be success
      End
    End

    Describe 'CC7: no staged files -> empty string'
      setup() {
        TMPDIR_SCOPE7=$(mktemp -d)
        git init "$TMPDIR_SCOPE7" >/dev/null 2>&1
        git -C "$TMPDIR_SCOPE7" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_SCOPE7"
      }
      cleanup() {
        rm -rf "$TMPDIR_SCOPE7"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns empty string when no files are staged'
        When call get_scope_from_diff
        The output should equal ""
        The status should be success
      End
    End
  End

  # Story: commit-message-accuracy, Task 2: get_type_from_diff()
  Describe 'get_type_from_diff()'
    Describe 'CC1: tests/spec/foo_spec.sh only -> type "test"'
      setup() {
        TMPDIR_TYPE1=$(mktemp -d)
        git init "$TMPDIR_TYPE1" >/dev/null 2>&1
        git -C "$TMPDIR_TYPE1" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        mkdir -p "$TMPDIR_TYPE1/tests/spec"
        echo 'test content' > "$TMPDIR_TYPE1/tests/spec/foo_spec.sh"
        git -C "$TMPDIR_TYPE1" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_TYPE1"
      }
      cleanup() {
        rm -rf "$TMPDIR_TYPE1"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns "test" when only tests/ files are staged'
        When call get_type_from_diff
        The output should equal "test"
        The status should be success
      End
    End

    Describe 'CC2: core/scripts/auto-commit.sh only -> type "feat"'
      setup() {
        TMPDIR_TYPE2=$(mktemp -d)
        git init "$TMPDIR_TYPE2" >/dev/null 2>&1
        git -C "$TMPDIR_TYPE2" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        mkdir -p "$TMPDIR_TYPE2/core/scripts"
        echo '#!/bin/bash' > "$TMPDIR_TYPE2/core/scripts/auto-commit.sh"
        git -C "$TMPDIR_TYPE2" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_TYPE2"
      }
      cleanup() {
        rm -rf "$TMPDIR_TYPE2"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns "feat" when only core/scripts/ files are staged'
        When call get_type_from_diff
        The output should equal "feat"
        The status should be success
      End
    End

    Describe 'CC3: .heartbeat/stories/x/board.jsonl only -> type "chore"'
      setup() {
        TMPDIR_TYPE3=$(mktemp -d)
        git init "$TMPDIR_TYPE3" >/dev/null 2>&1
        git -C "$TMPDIR_TYPE3" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        mkdir -p "$TMPDIR_TYPE3/.heartbeat/stories/x"
        echo '{"from":"tester"}' > "$TMPDIR_TYPE3/.heartbeat/stories/x/board.jsonl"
        git -C "$TMPDIR_TYPE3" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_TYPE3"
      }
      cleanup() {
        rm -rf "$TMPDIR_TYPE3"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns "chore" when only .heartbeat/ files are staged'
        When call get_type_from_diff
        The output should equal "chore"
        The status should be success
      End
    End

    Describe 'CC4: tests/ + core/scripts/ both -> type "feat"'
      setup() {
        TMPDIR_TYPE4=$(mktemp -d)
        git init "$TMPDIR_TYPE4" >/dev/null 2>&1
        git -C "$TMPDIR_TYPE4" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        mkdir -p "$TMPDIR_TYPE4/tests/spec"
        mkdir -p "$TMPDIR_TYPE4/core/scripts"
        echo 'test content' > "$TMPDIR_TYPE4/tests/spec/foo_spec.sh"
        echo '#!/bin/bash' > "$TMPDIR_TYPE4/core/scripts/auto-commit.sh"
        git -C "$TMPDIR_TYPE4" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_TYPE4"
      }
      cleanup() {
        rm -rf "$TMPDIR_TYPE4"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns "feat" when tests/ and core/scripts/ files are both staged'
        When call get_type_from_diff
        The output should equal "feat"
        The status should be success
      End
    End

    Describe 'CC5: README.md only -> type "chore"'
      setup() {
        TMPDIR_TYPE5=$(mktemp -d)
        git init "$TMPDIR_TYPE5" >/dev/null 2>&1
        git -C "$TMPDIR_TYPE5" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        echo '# readme' > "$TMPDIR_TYPE5/README.md"
        git -C "$TMPDIR_TYPE5" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_TYPE5"
      }
      cleanup() {
        rm -rf "$TMPDIR_TYPE5"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns "chore" when only README.md is staged'
        When call get_type_from_diff
        The output should equal "chore"
        The status should be success
      End
    End

    Describe 'CC6: no staged files -> type "chore"'
      setup() {
        TMPDIR_TYPE6=$(mktemp -d)
        git init "$TMPDIR_TYPE6" >/dev/null 2>&1
        git -C "$TMPDIR_TYPE6" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_TYPE6"
      }
      cleanup() {
        rm -rf "$TMPDIR_TYPE6"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns "chore" when no files are staged'
        When call get_type_from_diff
        The output should equal "chore"
        The status should be success
      End
    End
  End

  # Story: commit-message-accuracy, Task 3: get_description_from_diff()
  Describe 'get_description_from_diff()'
    Describe 'CC1: single file README.md modified -> "update README.md"'
      setup() {
        TMPDIR_DESC1=$(mktemp -d)
        git init "$TMPDIR_DESC1" >/dev/null 2>&1
        git -C "$TMPDIR_DESC1" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        echo '# readme' > "$TMPDIR_DESC1/README.md"
        git -C "$TMPDIR_DESC1" add -A >/dev/null 2>&1
        git -C "$TMPDIR_DESC1" \
          -c user.name="test" -c user.email="test@test.com" \
          commit -m "add readme" >/dev/null 2>&1
        echo '# updated readme' > "$TMPDIR_DESC1/README.md"
        git -C "$TMPDIR_DESC1" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_DESC1"
      }
      cleanup() {
        rm -rf "$TMPDIR_DESC1"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns "update README.md" for a single modified file'
        When call get_description_from_diff
        The output should equal "update README.md"
        The status should be success
      End
    End

    Describe 'CC2: 3 files in core/scripts/ -> "update 3 files in core/scripts"'
      setup() {
        TMPDIR_DESC2=$(mktemp -d)
        git init "$TMPDIR_DESC2" >/dev/null 2>&1
        git -C "$TMPDIR_DESC2" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        mkdir -p "$TMPDIR_DESC2/core/scripts"
        echo 'v1' > "$TMPDIR_DESC2/core/scripts/a.sh"
        echo 'v1' > "$TMPDIR_DESC2/core/scripts/b.sh"
        echo 'v1' > "$TMPDIR_DESC2/core/scripts/c.sh"
        git -C "$TMPDIR_DESC2" add -A >/dev/null 2>&1
        git -C "$TMPDIR_DESC2" \
          -c user.name="test" -c user.email="test@test.com" \
          commit -m "add scripts" >/dev/null 2>&1
        echo 'v2' > "$TMPDIR_DESC2/core/scripts/a.sh"
        echo 'v2' > "$TMPDIR_DESC2/core/scripts/b.sh"
        echo 'v2' > "$TMPDIR_DESC2/core/scripts/c.sh"
        git -C "$TMPDIR_DESC2" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_DESC2"
      }
      cleanup() {
        rm -rf "$TMPDIR_DESC2"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns "update 3 files in core/scripts" for multiple files in same directory'
        When call get_description_from_diff
        The output should equal "update 3 files in core/scripts"
        The status should be success
      End
    End

    Describe 'CC3: files across different directories -> "update N files across M directories"'
      setup() {
        TMPDIR_DESC3=$(mktemp -d)
        git init "$TMPDIR_DESC3" >/dev/null 2>&1
        git -C "$TMPDIR_DESC3" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        mkdir -p "$TMPDIR_DESC3/core/scripts"
        mkdir -p "$TMPDIR_DESC3/tests/spec"
        echo 'v1' > "$TMPDIR_DESC3/core/scripts/a.sh"
        echo 'v1' > "$TMPDIR_DESC3/tests/spec/a_spec.sh"
        git -C "$TMPDIR_DESC3" add -A >/dev/null 2>&1
        git -C "$TMPDIR_DESC3" \
          -c user.name="test" -c user.email="test@test.com" \
          commit -m "add files" >/dev/null 2>&1
        echo 'v2' > "$TMPDIR_DESC3/core/scripts/a.sh"
        echo 'v2' > "$TMPDIR_DESC3/tests/spec/a_spec.sh"
        git -C "$TMPDIR_DESC3" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_DESC3"
      }
      cleanup() {
        rm -rf "$TMPDIR_DESC3"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns "update 2 files across 2 directories" for files in different directories'
        When call get_description_from_diff
        The output should equal "update 2 files across 2 directories"
        The status should be success
      End
    End

    Describe 'CC4: new files only (git add) -> starts with "add"'
      setup() {
        TMPDIR_DESC4=$(mktemp -d)
        git init "$TMPDIR_DESC4" >/dev/null 2>&1
        git -C "$TMPDIR_DESC4" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        echo 'new file' > "$TMPDIR_DESC4/newfile.txt"
        git -C "$TMPDIR_DESC4" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_DESC4"
      }
      cleanup() {
        rm -rf "$TMPDIR_DESC4"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns description starting with "add" for a newly added file'
        When call get_description_from_diff
        The output should equal "add newfile.txt"
        The status should be success
      End
    End

    Describe 'CC5: long description (72+ chars) -> truncated by _truncate_description()'
      setup() {
        TMPDIR_DESC5=$(mktemp -d)
        git init "$TMPDIR_DESC5" >/dev/null 2>&1
        git -C "$TMPDIR_DESC5" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        # Create a file with a very long name to force truncation
        # "update " = 7 chars, filename needs 66+ chars to exceed 72 total
        echo 'content' > "$TMPDIR_DESC5/this-is-a-very-long-filename-that-will-cause-the-description-to-exceed-seventy-two-characters.txt"
        git -C "$TMPDIR_DESC5" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_DESC5"
      }
      cleanup() {
        rm -rf "$TMPDIR_DESC5"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      truncated_within_limit() {
        local output="$1"
        local len=${#output}
        [ "$len" -le 72 ]
      }

      It 'returns a description of 72 chars or less when input would exceed limit'
        When call get_description_from_diff
        The output should satisfy truncated_within_limit
        The status should be success
      End
    End

    Describe 'CC6: no staged files -> "update files"'
      setup() {
        TMPDIR_DESC6=$(mktemp -d)
        git init "$TMPDIR_DESC6" >/dev/null 2>&1
        git -C "$TMPDIR_DESC6" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_DESC6"
      }
      cleanup() {
        rm -rf "$TMPDIR_DESC6"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      It 'returns "update files" when no files are staged'
        When call get_description_from_diff
        The output should equal "update files"
        The status should be success
      End
    End
  End

  # Task 5, CC3: main() が全関数を組み合わせて Conventional Commits 形式の git commit を実行する
  Describe 'main() integration'
    setup() {
      TMPDIR_T5CC3=$(mktemp -d)

      # Initialize a git repo with an initial commit
      git init "$TMPDIR_T5CC3" >/dev/null 2>&1
      git -C "$TMPDIR_T5CC3" \
        -c user.name="test" -c user.email="test@test.com" \
        commit --allow-empty -m "initial" >/dev/null 2>&1

      # Create an unstaged change so main() has something to commit
      echo "new content" > "$TMPDIR_T5CC3/feature.txt"

      export CLAUDE_PROJECT_DIR="$TMPDIR_T5CC3"
    }
    cleanup() {
      rm -rf "$TMPDIR_T5CC3"
      unset CLAUDE_PROJECT_DIR
    }
    BeforeEach 'setup'
    AfterEach 'cleanup'

    run_main_and_get_commit_message() {
      echo '' \
        | "$SHELLSPEC_PROJECT_ROOT/core/scripts/auto-commit.sh" >/dev/null 2>&1
      git -C "$TMPDIR_T5CC3" log -1 --format=%s
    }

    It 'commits with Conventional Commits format derived from diff'
      When call run_main_and_get_commit_message
      The output should equal "chore(feature): add feature.txt"
      The status should be success
    End
  End

  # Story: commit-message-accuracy, Task 4: main() rewiring to new functions
  Describe 'main() rewiring (Task 4)'

    # Task 4, CC1: main() type is based on file paths (not agent name)
    Describe 'CC1: type is derived from file paths, not agent name'
      setup() {
        TMPDIR_T4W1=$(mktemp -d)
        git init "$TMPDIR_T4W1" >/dev/null 2>&1
        git -C "$TMPDIR_T4W1" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        # Pre-commit board.jsonl with agent "implementer" to prove it's NOT used
        mkdir -p "$TMPDIR_T4W1/.heartbeat/stories/some-story"
        echo '{"from":"implementer","note":"implement feature X"}' \
          > "$TMPDIR_T4W1/.heartbeat/stories/some-story/board.jsonl"
        git -C "$TMPDIR_T4W1" add -A >/dev/null 2>&1
        git -C "$TMPDIR_T4W1" \
          -c user.name="test" -c user.email="test@test.com" \
          commit -m "add board" --no-verify >/dev/null 2>&1
        # Create a test file -- type should be "test" based on file path
        mkdir -p "$TMPDIR_T4W1/tests/spec"
        echo 'test content' > "$TMPDIR_T4W1/tests/spec/example_spec.sh"
        export CLAUDE_PROJECT_DIR="$TMPDIR_T4W1"
      }
      cleanup() {
        rm -rf "$TMPDIR_T4W1"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      run_main_type_test() {
        echo '{"agent_type":"implementer"}' \
          | "$SHELLSPEC_PROJECT_ROOT/core/scripts/auto-commit.sh" >/dev/null 2>&1
        git -C "$TMPDIR_T4W1" log -1 --format=%s | sed 's/(.*//'
      }

      It 'uses type "test" for tests/ files even when agent is "implementer"'
        When call run_main_type_test
        The output should equal "test"
        The status should be success
      End
    End

    # Task 4, CC2: main() scope is story-id from board.jsonl (priority over file paths)
    Describe 'CC2: scope is story-id from board.jsonl, not file paths'
      setup() {
        TMPDIR_T4W2=$(mktemp -d)
        git init "$TMPDIR_T4W2" >/dev/null 2>&1
        git -C "$TMPDIR_T4W2" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        # Pre-commit board.jsonl with a DIFFERENT story ID to prove it's NOT used
        mkdir -p "$TMPDIR_T4W2/.heartbeat/stories/wrong-story"
        echo '{"from":"tester","note":"some note"}' \
          > "$TMPDIR_T4W2/.heartbeat/stories/wrong-story/board.jsonl"
        git -C "$TMPDIR_T4W2" add -A >/dev/null 2>&1
        git -C "$TMPDIR_T4W2" \
          -c user.name="test" -c user.email="test@test.com" \
          commit -m "add board" --no-verify >/dev/null 2>&1
        # Create a single file in core/scripts/ -- scope should be "auto-commit"
        mkdir -p "$TMPDIR_T4W2/core/scripts"
        echo '#!/bin/bash' > "$TMPDIR_T4W2/core/scripts/auto-commit.sh"
        export CLAUDE_PROJECT_DIR="$TMPDIR_T4W2"
      }
      cleanup() {
        rm -rf "$TMPDIR_T4W2"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      run_main_scope_test() {
        echo '{"agent_type":"tester"}' \
          | "$SHELLSPEC_PROJECT_ROOT/core/scripts/auto-commit.sh" >/dev/null 2>&1
        # Extract scope from commit message: type(SCOPE): desc
        git -C "$TMPDIR_T4W2" log -1 --format=%s | sed 's/^[^(]*(\([^)]*\)).*/\1/'
      }

      It 'uses scope "wrong-story" from board.jsonl, not "auto-commit" from file path'
        When call run_main_scope_test
        The output should equal "wrong-story"
        The status should be success
      End
    End

    # Task 4, CC3: main() description is based on file content (not board.jsonl .note)
    Describe 'CC3: description is derived from file changes, not board.jsonl .note'
      setup() {
        TMPDIR_T4W3=$(mktemp -d)
        git init "$TMPDIR_T4W3" >/dev/null 2>&1
        git -C "$TMPDIR_T4W3" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        # Pre-commit board.jsonl with a note that should NOT appear in commit
        mkdir -p "$TMPDIR_T4W3/.heartbeat/stories/my-story"
        echo '{"from":"tester","note":"completely different note from board"}' \
          > "$TMPDIR_T4W3/.heartbeat/stories/my-story/board.jsonl"
        git -C "$TMPDIR_T4W3" add -A >/dev/null 2>&1
        git -C "$TMPDIR_T4W3" \
          -c user.name="test" -c user.email="test@test.com" \
          commit -m "add board" --no-verify >/dev/null 2>&1
        # Create a new file
        echo 'new feature' > "$TMPDIR_T4W3/feature.txt"
        export CLAUDE_PROJECT_DIR="$TMPDIR_T4W3"
      }
      cleanup() {
        rm -rf "$TMPDIR_T4W3"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      run_main_desc_test() {
        echo '{"agent_type":"tester"}' \
          | "$SHELLSPEC_PROJECT_ROOT/core/scripts/auto-commit.sh" >/dev/null 2>&1
        # Extract description from commit message: type(scope): DESCRIPTION
        git -C "$TMPDIR_T4W3" log -1 --format=%s | sed 's/^[^:]*: //'
      }

      It 'uses "add feature.txt" from diff, not the board.jsonl note'
        When call run_main_desc_test
        The output should equal "add feature.txt"
        The status should be success
      End
    End

    # Task 4, CC4: board.jsonl .note is NOT used in commit message
    Describe 'CC4: board.jsonl .note does not appear in commit message'
      setup() {
        TMPDIR_T4W4=$(mktemp -d)
        git init "$TMPDIR_T4W4" >/dev/null 2>&1
        git -C "$TMPDIR_T4W4" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        echo 'content' > "$TMPDIR_T4W4/app.js"
        # board.jsonl with a distinctive note that must NOT appear in commit
        mkdir -p "$TMPDIR_T4W4/.heartbeat/stories/x-story"
        echo '{"from":"tester","note":"UNIQUE_BOARD_NOTE_MARKER"}' \
          > "$TMPDIR_T4W4/.heartbeat/stories/x-story/board.jsonl"
        export CLAUDE_PROJECT_DIR="$TMPDIR_T4W4"
      }
      cleanup() {
        rm -rf "$TMPDIR_T4W4"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      run_main_no_board_note() {
        echo '{}' \
          | "$SHELLSPEC_PROJECT_ROOT/core/scripts/auto-commit.sh" >/dev/null 2>&1
        git -C "$TMPDIR_T4W4" log -1 --format=%s
      }

      It 'produces a commit message that does not contain the board.jsonl note'
        When call run_main_no_board_note
        The output should not include "UNIQUE_BOARD_NOTE_MARKER"
        The status should be success
      End
    End

    # Task 4, CC5: Conventional Commits format type(scope): description is maintained
    Describe 'CC5: Conventional Commits format is maintained'
      setup() {
        TMPDIR_T4W5=$(mktemp -d)
        git init "$TMPDIR_T4W5" >/dev/null 2>&1
        git -C "$TMPDIR_T4W5" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        echo 'new content' > "$TMPDIR_T4W5/feature.txt"
        export CLAUDE_PROJECT_DIR="$TMPDIR_T4W5"
      }
      cleanup() {
        rm -rf "$TMPDIR_T4W5"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      run_main_format_test() {
        echo '' \
          | "$SHELLSPEC_PROJECT_ROOT/core/scripts/auto-commit.sh" >/dev/null 2>&1
        git -C "$TMPDIR_T4W5" log -1 --format=%s
      }

      It 'produces "chore(feature): add feature.txt" in Conventional Commits format'
        When call run_main_format_test
        The output should equal "chore(feature): add feature.txt"
        The status should be success
      End
    End

    # Task 4, CC6: Works on both platforms (with and without stdin JSON)
    Describe 'CC6: works with and without stdin JSON'
      Describe 'with stdin JSON'
        setup() {
          TMPDIR_T4W6A=$(mktemp -d)
          git init "$TMPDIR_T4W6A" >/dev/null 2>&1
          git -C "$TMPDIR_T4W6A" \
            -c user.name="test" -c user.email="test@test.com" \
            commit --allow-empty -m "initial" >/dev/null 2>&1
          echo 'content' > "$TMPDIR_T4W6A/feature.txt"
          export CLAUDE_PROJECT_DIR="$TMPDIR_T4W6A"
        }
        cleanup() {
          rm -rf "$TMPDIR_T4W6A"
          unset CLAUDE_PROJECT_DIR
        }
        BeforeEach 'setup'
        AfterEach 'cleanup'

        run_main_with_json() {
          echo '{"agent_type":"tester","last_assistant_message":"ignore this"}' \
            | "$SHELLSPEC_PROJECT_ROOT/core/scripts/auto-commit.sh" >/dev/null 2>&1
          git -C "$TMPDIR_T4W6A" log -1 --format=%s
        }

        It 'produces diff-based commit message even when stdin provides JSON'
          When call run_main_with_json
          The output should equal "chore(feature): add feature.txt"
          The status should be success
        End
      End

      Describe 'with empty stdin'
        setup() {
          TMPDIR_T4W6B=$(mktemp -d)
          git init "$TMPDIR_T4W6B" >/dev/null 2>&1
          git -C "$TMPDIR_T4W6B" \
            -c user.name="test" -c user.email="test@test.com" \
            commit --allow-empty -m "initial" >/dev/null 2>&1
          echo 'content' > "$TMPDIR_T4W6B/feature.txt"
          export CLAUDE_PROJECT_DIR="$TMPDIR_T4W6B"
        }
        cleanup() {
          rm -rf "$TMPDIR_T4W6B"
          unset CLAUDE_PROJECT_DIR
        }
        BeforeEach 'setup'
        AfterEach 'cleanup'

        run_main_with_empty() {
          echo '' \
            | "$SHELLSPEC_PROJECT_ROOT/core/scripts/auto-commit.sh" >/dev/null 2>&1
          git -C "$TMPDIR_T4W6B" log -1 --format=%s
        }

        It 'produces diff-based commit message with empty stdin'
          When call run_main_with_empty
          The output should equal "chore(feature): add feature.txt"
          The status should be success
        End
      End
    End
  End

  # Story: commit-message-accuracy, Task 6: Edge case tests
  Describe 'Edge cases (Task 6)'

    # Task 6, CC1: No staged files -> main() exits with code 0 early (no commit created)
    Describe 'CC1: main() exits early with code 0 when no staged files exist'
      setup() {
        TMPDIR_EDGE1=$(mktemp -d)
        git init "$TMPDIR_EDGE1" >/dev/null 2>&1
        git -C "$TMPDIR_EDGE1" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        # No changes at all -- working tree is clean
        export CLAUDE_PROJECT_DIR="$TMPDIR_EDGE1"
      }
      cleanup() {
        rm -rf "$TMPDIR_EDGE1"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      run_main_no_changes() {
        echo '' \
          | "$SHELLSPEC_PROJECT_ROOT/core/scripts/auto-commit.sh" 2>/dev/null
        echo $?
      }

      count_commits_after_main() {
        echo '' \
          | "$SHELLSPEC_PROJECT_ROOT/core/scripts/auto-commit.sh" 2>/dev/null
        # Count commits -- should still be just the initial one
        git -C "$TMPDIR_EDGE1" rev-list --count HEAD
      }

      It 'exits with code 0 when there are no changes'
        When call run_main_no_changes
        The output should equal "0"
        The status should be success
      End

      It 'does not create a new commit when there are no changes'
        When call count_commits_after_main
        The output should equal "1"
        The status should be success
      End
    End

    # Task 6, CC2: Many files changed -> description is 72 characters or less
    Describe 'CC2: description stays within 72 chars for many files'
      setup() {
        TMPDIR_EDGE2=$(mktemp -d)
        git init "$TMPDIR_EDGE2" >/dev/null 2>&1
        git -C "$TMPDIR_EDGE2" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        # Create 100 files spread across many directories to force a long description
        local i=0
        while [ "$i" -lt 100 ]; do
          local dir_name="dir-with-a-long-name-for-testing-purposes-$(printf '%02d' $i)"
          mkdir -p "$TMPDIR_EDGE2/$dir_name"
          echo "content $i" > "$TMPDIR_EDGE2/$dir_name/file-$i.txt"
          i=$((i + 1))
        done
        git -C "$TMPDIR_EDGE2" add -A >/dev/null 2>&1
        export CLAUDE_PROJECT_DIR="$TMPDIR_EDGE2"
      }
      cleanup() {
        rm -rf "$TMPDIR_EDGE2"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      desc_within_72_chars() {
        local output="$1"
        local len=${#output}
        [ "$len" -le 72 ]
      }

      It 'produces a description of 72 chars or less even with 100 files across many directories'
        When call get_description_from_diff
        The output should satisfy desc_within_72_chars
        The status should be success
      End
    End

    # Task 6, CC3: .heartbeat/ only changes -> type is "chore"
    Describe 'CC3: .heartbeat/ only changes produce type "chore" in full main() flow'
      setup() {
        TMPDIR_EDGE3=$(mktemp -d)
        git init "$TMPDIR_EDGE3" >/dev/null 2>&1
        git -C "$TMPDIR_EDGE3" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        # Create multiple .heartbeat/ files across different story dirs
        mkdir -p "$TMPDIR_EDGE3/.heartbeat/stories/story-a"
        mkdir -p "$TMPDIR_EDGE3/.heartbeat/stories/story-b"
        echo '{"from":"tester"}' > "$TMPDIR_EDGE3/.heartbeat/stories/story-a/board.jsonl"
        echo '# tasks' > "$TMPDIR_EDGE3/.heartbeat/stories/story-a/tasks.md"
        echo '{"from":"designer"}' > "$TMPDIR_EDGE3/.heartbeat/stories/story-b/board.jsonl"
        export CLAUDE_PROJECT_DIR="$TMPDIR_EDGE3"
      }
      cleanup() {
        rm -rf "$TMPDIR_EDGE3"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      run_main_heartbeat_only() {
        echo '' \
          | "$SHELLSPEC_PROJECT_ROOT/core/scripts/auto-commit.sh" >/dev/null 2>&1
        # Extract type from commit message (everything before the first parenthesis or colon)
        git -C "$TMPDIR_EDGE3" log -1 --format=%s | sed 's/[(:].*//'
      }

      It 'uses type "chore" when only .heartbeat/ files are changed'
        When call run_main_heartbeat_only
        The output should equal "chore"
        The status should be success
      End
    End

    # Task 6, CC4: New functions do not depend on jq (bash + git only)
    Describe 'CC4: new functions do not depend on jq'
      # Verify by source code inspection: grep for jq usage in the new functions
      # The new functions are: get_scope_from_diff, get_type_from_diff,
      # get_description_from_diff, _get_staged_files, _count_lines, _all_files_match

      new_functions_free_of_jq() {
        local script="$SHELLSPEC_PROJECT_ROOT/core/scripts/auto-commit.sh"
        # Extract function bodies of the new functions and check for jq
        # We check that jq does NOT appear between function def and closing brace
        # for each new function
        local funcs="get_scope_from_diff get_type_from_diff get_description_from_diff _get_staged_files _count_lines _all_files_match"
        for func_name in $funcs; do
          # Extract function body using sed: from "func_name()" to next "^}"
          local body
          body=$(sed -n "/^${func_name}()/,/^}/p" "$script")
          if echo "$body" | grep -q 'jq '; then
            echo "FAIL: $func_name uses jq"
            return 1
          fi
        done
        echo "PASS"
        return 0
      }

      It 'confirms none of the new functions call jq'
        When call new_functions_free_of_jq
        The output should equal "PASS"
        The status should be success
      End
    End
  End

  # Story: commit-scope-storyid, Task 1: main() は get_story_scope() を優先し、空の場合 get_scope_from_diff() にフォールバックする
  Describe 'main() story scope priority (commit-scope-storyid)'

    # Task 1, CC1: board.jsonl が存在する場合、スコープがストーリーIDになる
    Describe 'CC1: scope is story-id when board.jsonl exists'
      setup() {
        TMPDIR_SS1=$(mktemp -d)
        git init "$TMPDIR_SS1" >/dev/null 2>&1
        git -C "$TMPDIR_SS1" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        # Pre-commit board.jsonl so get_story_scope() returns "my-active-story"
        mkdir -p "$TMPDIR_SS1/.heartbeat/stories/my-active-story"
        echo '{"from":"tester","note":"test note"}' \
          > "$TMPDIR_SS1/.heartbeat/stories/my-active-story/board.jsonl"
        git -C "$TMPDIR_SS1" add -A >/dev/null 2>&1
        git -C "$TMPDIR_SS1" \
          -c user.name="test" -c user.email="test@test.com" \
          commit -m "add board" --no-verify >/dev/null 2>&1
        # Create a test file -- get_scope_from_diff() would return "tests"
        # but get_story_scope() should return "my-active-story" and take priority
        mkdir -p "$TMPDIR_SS1/tests/spec"
        echo 'test content' > "$TMPDIR_SS1/tests/spec/example_spec.sh"
        echo 'test content2' > "$TMPDIR_SS1/tests/spec/another_spec.sh"
        export CLAUDE_PROJECT_DIR="$TMPDIR_SS1"
      }
      cleanup() {
        rm -rf "$TMPDIR_SS1"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      run_main_story_scope() {
        echo '' \
          | "$SHELLSPEC_PROJECT_ROOT/core/scripts/auto-commit.sh" >/dev/null 2>&1
        # Extract scope from commit message: type(SCOPE): desc
        git -C "$TMPDIR_SS1" log -1 --format=%s | sed 's/^[^(]*(\([^)]*\)).*/\1/'
      }

      It 'uses story-id "my-active-story" as scope instead of "tests" from file paths'
        When call run_main_story_scope
        The output should equal "my-active-story"
        The status should be success
      End
    End

    # Task 2, CC1: board.jsonl が存在しない場合、get_scope_from_diff() のフォールバックが使われる
    Describe 'CC1: scope falls back to get_scope_from_diff() when no board.jsonl exists'
      setup() {
        TMPDIR_SS2=$(mktemp -d)
        git init "$TMPDIR_SS2" >/dev/null 2>&1
        git -C "$TMPDIR_SS2" \
          -c user.name="test" -c user.email="test@test.com" \
          commit --allow-empty -m "initial" >/dev/null 2>&1
        # NO board.jsonl -- no .heartbeat/stories/ at all
        # Create test files so get_scope_from_diff() would return "tests"
        mkdir -p "$TMPDIR_SS2/tests/spec"
        echo 'test content' > "$TMPDIR_SS2/tests/spec/fallback_spec.sh"
        echo 'test content2' > "$TMPDIR_SS2/tests/spec/fallback2_spec.sh"
        export CLAUDE_PROJECT_DIR="$TMPDIR_SS2"
      }
      cleanup() {
        rm -rf "$TMPDIR_SS2"
        unset CLAUDE_PROJECT_DIR
      }
      BeforeEach 'setup'
      AfterEach 'cleanup'

      run_main_fallback_scope() {
        echo '' \
          | "$SHELLSPEC_PROJECT_ROOT/core/scripts/auto-commit.sh" >/dev/null 2>&1
        # Extract scope from commit message: type(SCOPE): desc
        git -C "$TMPDIR_SS2" log -1 --format=%s | sed 's/^[^(]*(\([^)]*\)).*/\1/'
      }

      It 'uses "tests" from get_scope_from_diff() when no board.jsonl exists'
        When call run_main_fallback_scope
        The output should equal "tests"
        The status should be success
      End
    End
  End
End
