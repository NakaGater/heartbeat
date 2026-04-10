import { Placeholder } from '../Placeholder';

// InsightsPanel: 単独の bento-card として配置される。
// design.md「コンポーネント仕様」: grid-column: 1 / -1, .card-insights クラス。
// 0059b で実装差し替え予定。
export function InsightsPanel() {
  return <Placeholder name="InsightsPanel" className="bento-card card-insights" />;
}
