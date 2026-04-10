// Sidebar: 画面左端に固定配置されるナビゲーション。
// design.md「コンポーネント仕様」: position: fixed; left: 0; width: 48px。
// <nav> 要素で暗黙の navigation ロールを付与 (design.md「アクセシビリティ」)。
// 実体は Sidebar.tsx を参照し、ここでは再エクスポートのみ行う。
export { Sidebar } from './Sidebar';
