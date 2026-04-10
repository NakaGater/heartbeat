/**
 * App: Bento グリッドレイアウトと 7 つの本実装コンポーネントの配置。
 *
 * 由来: design.md §5「データフロー: App.tsx で一度だけ読む」。
 *   window.BACKLOG_DATA / STORIES_DATA / AGENT_COLORS / INSIGHTS_DATA を
 *   この関数冒頭で 1 度だけ読み取り、各コンポーネントに props として分配する。
 *   ランタイム状態は選択中ストーリー ID のみ (StoryDetail と AgentMessages で共有)。
 *
 * 配置ポリシー:
 *   - Sidebar: bento-grid の外側 (position: fixed)。
 *   - HeroMetrics / StoryDetail / AgentMessages / InsightsPanel:
 *     bento-grid 直下の grid item (grid-column: 1 / -1)。
 *     StoryDetail / AgentMessages / InsightsPanel の `bento-card card-xxx`
 *     ラッパは design.md §9.2 に従い各コンポーネント内部に閉じている。
 *   - BacklogBoard + VelocityChart: card-backlog-velocity > card-split の中に
 *     2 分割で同居する (bento-card ラッパは App 側で保持)。
 */
import { useMemo, useState } from 'react';
import { HeroMetrics } from './components/HeroMetrics';
import { BacklogBoard } from './components/BacklogBoard';
import { VelocityChart } from './components/VelocityChart';
import { StoryDetail } from './components/StoryDetail';
import { AgentMessages } from './components/AgentMessages';
import { InsightsPanel } from './components/InsightsPanel';
import { Sidebar } from './components/Sidebar';
import type {
  BacklogStory,
  StoryDetailData,
  AgentColors,
  InsightsData,
} from './types';

const EMPTY_INSIGHTS: InsightsData = {
  raw: [],
  findings: [],
  insights: [],
  opportunities: [],
};

// window グローバルを安全に読み出すためのヘルパ。generate-dashboard.sh は
// 型検証をしないので、App.tsx 境界で Array.isArray / typeof guards をかける
// (design.md §3.2)。
function readBacklog(): BacklogStory[] {
  const raw = (window as unknown as { BACKLOG_DATA?: unknown }).BACKLOG_DATA;
  return Array.isArray(raw) ? (raw as BacklogStory[]) : [];
}

function readStories(): StoryDetailData[] {
  const raw = (window as unknown as { STORIES_DATA?: unknown }).STORIES_DATA;
  return Array.isArray(raw) ? (raw as StoryDetailData[]) : [];
}

function readAgentColors(): AgentColors {
  const raw = (window as unknown as { AGENT_COLORS?: unknown }).AGENT_COLORS;
  if (raw && typeof raw === 'object' && !Array.isArray(raw)) {
    return raw as AgentColors;
  }
  return {};
}

function readInsights(): InsightsData {
  const raw = (window as unknown as { INSIGHTS_DATA?: unknown }).INSIGHTS_DATA;
  if (raw && typeof raw === 'object' && !Array.isArray(raw)) {
    const d = raw as Partial<InsightsData>;
    return {
      raw: Array.isArray(d.raw) ? d.raw : [],
      findings: Array.isArray(d.findings) ? d.findings : [],
      insights: Array.isArray(d.insights) ? d.insights : [],
      opportunities: Array.isArray(d.opportunities) ? d.opportunities : [],
    };
  }
  return EMPTY_INSIGHTS;
}

export function App() {
  // 1. window グローバルを 1 回だけ読む (ランタイム防御込み)
  const backlog = useMemo(readBacklog, []);
  const stories = useMemo(readStories, []);
  const agentColors = useMemo(readAgentColors, []);
  const insights = useMemo(readInsights, []);

  // 2. 選択中ストーリー ID。in_progress 優先、なければ先頭、stories 空なら ''。
  const initialSelectedId = useMemo(() => {
    const inProgress = stories.find((s) => s.status === 'in_progress');
    if (inProgress) return inProgress.story_id;
    return stories[0]?.story_id ?? '';
  }, [stories]);

  const [selectedStoryId, setSelectedStoryId] = useState<string>(initialSelectedId);

  return (
    <>
      <Sidebar />
      <div id="app" className="bento-grid">
        <HeroMetrics backlog={backlog} />
        <div className="bento-card card-backlog-velocity">
          <div className="card-split">
            <BacklogBoard backlog={backlog} currentStoryId={selectedStoryId} />
            <VelocityChart backlog={backlog} />
          </div>
        </div>
        <StoryDetail
          stories={stories}
          agentColors={agentColors}
          selectedStoryId={selectedStoryId}
          onSelectStory={setSelectedStoryId}
        />
        <AgentMessages
          stories={stories}
          agentColors={agentColors}
          selectedStoryId={selectedStoryId}
        />
        <InsightsPanel data={insights} />
      </div>
    </>
  );
}
