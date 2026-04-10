/**
 * App: Bento グリッドレイアウトと 7 つのプレースホルダーコンポーネントの配置。
 *
 * 由来: design.md「コンポーネント仕様」の App.tsx 構造をそのまま実装。
 *   既存 core/templates/dashboard.html の DOM 構造を React に転写することで、
 *   0059b での実コンポーネント差し替え時にレイアウト崩れのリスクを最小化する。
 *
 * 配置ポリシー:
 *   - Sidebar: bento-grid の外側に置く (position: fixed で viewport に貼り付く)。
 *   - HeroMetrics / StoryDetail / AgentMessages / InsightsPanel:
 *     bento-grid 直下の grid item (grid-column: 1 / -1)。
 *   - BacklogBoard + VelocityChart: card-backlog-velocity > card-split の中に
 *     2 分割で同居する。
 */
import { HeroMetrics } from './components/HeroMetrics';
import { BacklogBoard } from './components/BacklogBoard';
import { VelocityChart } from './components/VelocityChart';
import { StoryDetail } from './components/StoryDetail';
import { AgentMessages } from './components/AgentMessages';
import { InsightsPanel } from './components/InsightsPanel';
import { Sidebar } from './components/Sidebar';

export function App() {
  return (
    <>
      <Sidebar />
      <div id="app" className="bento-grid">
        <HeroMetrics />
        <div className="bento-card card-backlog-velocity">
          <div className="card-split">
            <BacklogBoard />
            <VelocityChart />
          </div>
        </div>
        <StoryDetail />
        <AgentMessages />
        <InsightsPanel />
      </div>
    </>
  );
}
