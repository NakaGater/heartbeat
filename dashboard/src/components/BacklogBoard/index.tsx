import { Placeholder } from '../Placeholder';

// BacklogBoard: card-backlog-velocity > card-split の左半分に配置される
// カンバンパネル。親 bento-card の内部要素のため、自身は bento-card クラスを持たない。
// 0059b で実装差し替え予定。
export function BacklogBoard() {
  return <Placeholder name="BacklogBoard" className="backlog-board" />;
}
