import { Placeholder } from '../Placeholder';

// AgentMessages: 単独の bento-card として配置される。
// design.md「コンポーネント仕様」: grid-column: 1 / -1, .card-messages クラス。
// 0059b で実装差し替え予定。
export function AgentMessages() {
  return <Placeholder name="AgentMessages" className="bento-card card-messages" />;
}
