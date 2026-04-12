# Dashboard

Heartbeat プロジェクトのダッシュボード UI（React + TypeScript + Vite）。

## 開発環境セットアップ

```bash
cd dashboard
npm install        # 依存関係のインストール
npm run dev        # Vite 開発サーバ起動（ホットリロード付き）
npm run build      # 本番ビルド → dashboard/dist/index.html に単一 HTML を出力
npx vitest         # Vitest でコンポーネントテストを実行（watch モード）
npx vitest run     # 1 回だけ実行して終了
```

主要ディレクトリ:

- `dashboard/src/components/<Component>/` — 各コンポーネントと `*.test.tsx`
- `dashboard/dist/index.html` — Vite ビルド成果物（**リポジトリにコミット済み**）

## 本番利用フロー

1. UI を編集した後、必ず `npm run build` を実行して `dashboard/dist/index.html` を再生成する
2. 再生成した `dashboard/dist/index.html` を **コミットする**
3. ランタイムの `core/scripts/generate-dashboard.sh` は `dashboard/dist/index.html` をテンプレートとして読み込み、`.heartbeat/` 配下の JSONL データ（`BACKLOG_DATA` / `STORIES_DATA` / `AGENT_COLORS` / `INSIGHTS_DATA`）を `window.*` 代入文のプレースホルダに差し込んで `.heartbeat/dashboard.html` を出力する
4. このため **Heartbeat を利用するエンドユーザー側に Node.js / npm は不要**。jq のみが外部依存として必要（既存の Heartbeat プロジェクト要件と同じ）

### Node.js 非依存性の検証

```bash
PATH=/usr/bin:/bin:/opt/homebrew/bin bash core/scripts/generate-dashboard.sh .
# node/npm が PATH に無くても .heartbeat/dashboard.html が生成されることを確認できる
```

## テスト戦略

- **Vitest + React Testing Library**: 各コンポーネント（HeroMetrics / BacklogBoard / VelocityChart / StoryDetail / AgentMessages / InsightsPanel / Sidebar）は `dashboard/src/components/<Component>/<Component>.test.tsx` に単体テストを持つ
- **ShellSpec 静的 HTML パターンマッチングテスト**: 旧ダッシュボード（単一 HTML にインライン JS を埋め込む ES5 実装）に依存した 23 本のテストは story 0059c で廃止した。加えて 0059a から繰り越されていた 10 本の legacy failing test（`gantt_*`・`dashboard_integration`・`dashboard_insights_panel` 他）も同時に削除した
- 旧 ShellSpec テストと新 Vitest テストのカバレッジマッピング:
  `.heartbeat/stories/0059c-dashboard-react-test-migration/coverage-mapping.md` を参照

## ES5 制約の撤廃記録

story 0059 以前は `core/templates/dashboard.html` が単一 HTML ファイルにインライン `<script>` を直接埋め込む構造だった。このため:

- JavaScript は ES5 構文に制限されていた（`var` のみ、アロー関数/`const`/`let`/モジュール禁止）
- コンポーネント分割やテストがほぼ不可能で、`grep` による文字列マッチングに頼る静的検証しか行えなかった

story 0059a-0059c（2026-03 〜 2026-04）で以下を完了し、この制約を撤廃した:

- 0059a: Vite + React + TypeScript のプロジェクト構造を確立し、`dashboard/dist/index.html` を `generate-dashboard.sh` のテンプレートとして組み込んだ（Node.js 非依存を維持）
- 0059b: 7 コンポーネントを React + TypeScript で実装し、Vitest による単体テストを追加
- 0059c（本ストーリー）: 旧 ShellSpec 静的パターンマッチテスト 23 本と 0059a から繰り越されていた legacy failing test 10 本を削除し、テスト基盤を Vitest に一本化

以降、ダッシュボード UI ではモダンな ES / TypeScript / JSX / ES モジュール構文を自由に利用してよい。
