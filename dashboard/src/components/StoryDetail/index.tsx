import { Placeholder } from '../Placeholder';

// StoryDetail: 単独の bento-card として配置される。
// design.md「コンポーネント仕様」: grid-column: 1 / -1, .card-story クラス。
// 0059b で実装差し替え予定。
export function StoryDetail() {
  return <Placeholder name="StoryDetail" className="bento-card card-story" />;
}
