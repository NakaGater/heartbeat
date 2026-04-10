/**
 * Placeholder: 0059a 基盤構築スコープにおける未実装コンポーネントの共通表示。
 *
 * 由来: design.md「プレースホルダーコンポーネントパターン」
 *   7 コンポーネント (HeroMetrics / BacklogBoard / VelocityChart / StoryDetail /
 *   AgentMessages / InsightsPanel / Sidebar) がすべて同一の「名前 + 未実装ラベル」
 *   を表示する仕様のため、ここに DRY で抽出している。
 *
 * 設計意図:
 *   - `className` は呼び出し側が完全制御する (例: "hero-metrics placeholder-component",
 *     "bento-card card-story placeholder-component")。これにより design.md
 *     「コンポーネント仕様」表で定義された既存 CSS クラスを各コンポーネントが
 *     そのまま維持できる (0059b 実装差し替え時の CSS 変更を不要にする)。
 *   - `as` prop で要素を差し替え可能にし、Sidebar が <nav> を使えるようにする。
 *   - ラベル文字列 "0059b で実装予定" をこの 1 箇所に集約する。0059b 着手時は
 *     この Placeholder を import するコードを実装版に置換していくだけで済む。
 *
 * このファイル自体は「コンポーネント名を index.tsx ファイル内に含むこと」という
 * テスト (app_skeleton_spec.sh AC3) の対象外 (ディレクトリ直下の helper)。
 */
import type { ElementType, ReactElement } from 'react';

export interface PlaceholderProps {
  /** コンポーネント名。表示ラベルとして使用する。 */
  name: string;
  /** ルート要素に適用する CSS クラス (既存 dashboard.html 由来のクラス名)。 */
  className: string;
  /** ルート要素のタグ。既定は <div>。Sidebar のみ "nav" を指定する。 */
  as?: ElementType;
}

/** 0059b で実装予定であることを示す共通ラベル。 */
const PLACEHOLDER_STATUS_LABEL = '0059b で実装予定';

export function Placeholder({
  name,
  className,
  as: Tag = 'div',
}: PlaceholderProps): ReactElement {
  return (
    <Tag className={`${className} placeholder-component`}>
      <div className="placeholder-label">
        <span className="placeholder-name">{name}</span>
        <span className="placeholder-status">{PLACEHOLDER_STATUS_LABEL}</span>
      </div>
    </Tag>
  );
}
