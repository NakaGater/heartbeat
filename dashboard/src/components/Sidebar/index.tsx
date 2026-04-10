import { Placeholder } from '../Placeholder';

// Sidebar: 画面左端に固定配置されるナビゲーション。
// design.md「コンポーネント仕様」: position: fixed; left: 0; width: 48px。
// <nav> 要素で暗黙の navigation ロールを付与 (design.md「アクセシビリティ」)。
// 0059b で実装差し替え予定。
export function Sidebar() {
  return <Placeholder name="Sidebar" className="sidebar" as="nav" />;
}
