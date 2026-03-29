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

  # Task 5, CC3: main() が全関数を組み合わせて Conventional Commits 形式の git commit を実行する
  Describe 'main() integration'
    setup() {
      TMPDIR_T5CC3=$(mktemp -d)

      # Initialize a git repo with an initial commit
      git init "$TMPDIR_T5CC3" >/dev/null 2>&1
      git -C "$TMPDIR_T5CC3" \
        -c user.name="test" -c user.email="test@test.com" \
        commit --allow-empty -m "initial" >/dev/null 2>&1

      # Set up board.jsonl with story scope and note
      mkdir -p "$TMPDIR_T5CC3/.heartbeat/stories/auto-commit-fix"
      echo '{"from":"tester","note":"add login test"}' \
        > "$TMPDIR_T5CC3/.heartbeat/stories/auto-commit-fix/board.jsonl"

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
      echo '{"agent_type":"tester"}' \
        | "$SHELLSPEC_PROJECT_ROOT/core/scripts/auto-commit.sh" >/dev/null 2>&1
      git -C "$TMPDIR_T5CC3" log -1 --format=%s
    }

    It 'commits with Conventional Commits format using all helper functions'
      When call run_main_and_get_commit_message
      The output should equal "test(auto-commit-fix): add login test"
      The status should be success
    End
  End
End
