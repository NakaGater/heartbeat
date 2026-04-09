Describe 'dashboard.html: Dark-first Design Token System v2 (Task 1)'
  TEMPLATE="core/templates/dashboard.html"

  # --- AC1: Background tokens are defined on :root ---
  Describe 'AC1: :root Dark Default Background Tokens'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It 'defines --bg on :root (dark default #080c19)'
      When call root_block
      The output should include '--bg: #080c19'
    End

    It 'defines --bg-panel on :root'
      When call root_block
      The output should include '--bg-panel:'
    End

    It 'defines --bg-card on :root'
      When call root_block
      The output should include '--bg-card:'
    End

    It 'defines --bg-elevated on :root'
      When call root_block
      The output should include '--bg-elevated:'
    End
  End

  # --- AC2: Accent color scale is defined on :root ---
  Describe 'AC2: :root Accent Color Scale'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It 'defines --accent on :root'
      When call root_block
      The output should include '--accent:'
    End

    It 'defines --accent-hover on :root'
      When call root_block
      The output should include '--accent-hover:'
    End

    It 'defines --accent-subtle on :root'
      When call root_block
      The output should include '--accent-subtle:'
    End

    It 'defines --accent-muted on :root'
      When call root_block
      The output should include '--accent-muted:'
    End

    It 'defines --accent-glow on :root'
      When call root_block
      The output should include '--accent-glow:'
    End
  End

  # --- AC3: Semantic colors and -subtle variants are defined on :root ---
  Describe 'AC3: :root Semantic Colors + Subtle Variants'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It 'defines --secondary and --secondary-subtle on :root'
      When call root_block
      The output should include '--secondary:'
      The output should include '--secondary-subtle:'
    End

    It 'defines --tertiary and --tertiary-subtle on :root'
      When call root_block
      The output should include '--tertiary:'
      The output should include '--tertiary-subtle:'
    End

    It 'defines --success and --success-subtle on :root'
      When call root_block
      The output should include '--success:'
      The output should include '--success-subtle:'
    End

    It 'defines --warning and --warning-subtle on :root'
      When call root_block
      The output should include '--warning:'
      The output should include '--warning-subtle:'
    End

    It 'defines --error and --error-subtle on :root'
      When call root_block
      The output should include '--error:'
      The output should include '--error-subtle:'
    End

    It 'defines --info and --info-subtle on :root'
      When call root_block
      The output should include '--info:'
      The output should include '--info-subtle:'
    End
  End

  # --- AC4: Gradient tokens are defined on :root ---
  Describe 'AC4: :root Gradient Tokens'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It 'defines --gradient-primary on :root'
      When call root_block
      The output should include '--gradient-primary:'
    End

    It 'defines --gradient-hero on :root'
      When call root_block
      The output should include '--gradient-hero:'
    End

    It 'defines --gradient-surface on :root'
      When call root_block
      The output should include '--gradient-surface:'
    End

    It 'defines --gradient-mesh (mesh gradient) on :root'
      When call root_block
      The output should include '--gradient-mesh:'
    End

    It 'defines --gradient-header on :root'
      When call root_block
      The output should include '--gradient-header:'
    End
  End

  # --- AC5: 4px-based spacing --space-1 through --space-8 are defined on :root ---
  Describe 'AC5: :root Spacing Tokens (4px Base)'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It 'defines --space-1: 4px on :root'
      When call root_block
      The output should include '--space-1: 4px'
    End

    It 'defines --space-2: 8px on :root'
      When call root_block
      The output should include '--space-2: 8px'
    End

    It 'defines --space-3: 12px on :root'
      When call root_block
      The output should include '--space-3: 12px'
    End

    It 'defines --space-4: 16px on :root'
      When call root_block
      The output should include '--space-4: 16px'
    End

    It 'defines --space-5: 24px on :root'
      When call root_block
      The output should include '--space-5: 24px'
    End

    It 'defines --space-6: 32px on :root'
      When call root_block
      The output should include '--space-6: 32px'
    End

    It 'defines --space-7: 48px on :root'
      When call root_block
      The output should include '--space-7: 48px'
    End

    It 'defines --space-8: 64px on :root'
      When call root_block
      The output should include '--space-8: 64px'
    End
  End

  # --- AC6: Shadow tokens are defined on :root ---
  Describe 'AC6: :root Shadow Tokens'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It 'defines --shadow-xs on :root'
      When call root_block
      The output should include '--shadow-xs:'
    End

    It 'defines --shadow-sm on :root'
      When call root_block
      The output should include '--shadow-sm:'
    End

    It 'defines --shadow-md on :root'
      When call root_block
      The output should include '--shadow-md:'
    End

    It 'defines --shadow-lg on :root'
      When call root_block
      The output should include '--shadow-lg:'
    End

    It 'defines --shadow-2xl on :root'
      When call root_block
      The output should include '--shadow-2xl:'
    End

    It 'defines --shadow-glow on :root'
      When call root_block
      The output should include '--shadow-glow:'
    End
  End

  # --- AC7: Border radius tokens are defined on :root ---
  Describe 'AC7: :root Border Radius Tokens'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It 'defines --radius-sm on :root'
      When call root_block
      The output should include '--radius-sm:'
    End

    It 'defines --radius-md on :root'
      When call root_block
      The output should include '--radius-md:'
    End

    It 'defines --radius-lg on :root'
      When call root_block
      The output should include '--radius-lg:'
    End

    It 'defines --radius-xl on :root'
      When call root_block
      The output should include '--radius-xl:'
    End

    It 'defines --radius-full on :root'
      When call root_block
      The output should include '--radius-full:'
    End
  End

  # --- AC8: Type scale --text-2xs through --text-4xl are defined on :root ---
  Describe 'AC8: :root Type Scale'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It 'defines --text-2xs on :root'
      When call root_block
      The output should include '--text-2xs:'
    End

    It 'defines --text-xs on :root'
      When call root_block
      The output should include '--text-xs:'
    End

    It 'defines --text-sm on :root'
      When call root_block
      The output should include '--text-sm:'
    End

    It 'defines --text-md on :root'
      When call root_block
      The output should include '--text-md:'
    End

    It 'defines --text-base on :root'
      When call root_block
      The output should include '--text-base:'
    End

    It 'defines --text-lg on :root'
      When call root_block
      The output should include '--text-lg:'
    End

    It 'defines --text-xl on :root'
      When call root_block
      The output should include '--text-xl:'
    End

    It 'defines --text-2xl on :root'
      When call root_block
      The output should include '--text-2xl:'
    End

    It 'defines --text-3xl on :root'
      When call root_block
      The output should include '--text-3xl:'
    End

    It 'defines --text-4xl on :root'
      When call root_block
      The output should include '--text-4xl:'
    End
  End

  # --- AC9: Light mode variables are overridden via prefers-color-scheme: light ---
  Describe 'AC9: Light Mode (prefers-color-scheme: light) Overrides'
    light_block() {
      sed -n '/prefers-color-scheme:[[:space:]]*light/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It 'contains prefers-color-scheme: light media query'
      The contents of file "$TEMPLATE" should include 'prefers-color-scheme: light'
    End

    It 'overrides --bg in light mode'
      When call light_block
      The output should include '--bg:'
    End

    It 'overrides --text in light mode'
      When call light_block
      The output should include '--text:'
    End

    It 'overrides --accent in light mode'
      When call light_block
      The output should include '--accent:'
    End

    It 'overrides --shadow-sm in light mode'
      When call light_block
      The output should include '--shadow-sm:'
    End

    It 'overrides --gradient-primary in light mode'
      When call light_block
      The output should include '--gradient-primary:'
    End

    It 'overrides --gradient-mesh in light mode'
      When call light_block
      The output should include '--gradient-mesh:'
    End
  End

  # --- AC10: Light mode color values are independently optimized, not simple inversions of dark ---
  Describe 'AC10: Light Mode Color Values Are Independently Optimized'
    light_block() {
      sed -n '/prefers-color-scheme:[[:space:]]*light/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It 'uses a light value for --bg in light mode (not #080c19)'
      When call light_block
      The output should not include '--bg: #080c19'
    End

    It 'uses a different --accent value in light mode than dark #7c6aef'
      When call light_block
      The output should include '--accent:'
      The output should not include '--accent: #7c6aef'
    End

    It 'uses lighter opacity for --shadow-sm in light mode than dark'
      When call light_block
      The output should include '--shadow-sm:'
      # Dark mode is rgba(0,0,0,0.3) but light mode should have a smaller value
      The output should not include 'rgba(0, 0, 0, 0.3)'
    End
  End
End
