/**
 * 0059b タスク8で導入した共通型モジュール。
 *
 * 由来: design.md §3.1「共有型モジュール」。
 * 各コンポーネントがタスク 1〜7 の実装時にローカルで宣言していた
 * *Like インタフェース群を、App.tsx 統合のタイミングで 1 ファイルに集約する。
 *
 * 設計方針:
 *   - `generate-dashboard.sh` は JSON を埋め込むだけで型検証しない。
 *     したがって App.tsx 境界で Array.isArray / ?? によるランタイム防御を行う
 *     (design.md §3.2)。
 *   - 各コンポーネントの既存ローカル型 (BacklogStoryLike など) は、
 *     ここで宣言する型のサブセット/互換形状となっている。既存の
 *     コンポーネントシグネチャは破壊せず、App.tsx がこの型に基づく値を
 *     渡すことで構造的型付けにより受け入れられる。
 */

export type StoryStatus = 'draft' | 'ready' | 'in_progress' | 'done';
export type BoardEntryStatus =
  | 'pending'
  | 'in_progress'
  | 'done'
  | 'blocked'
  | 'rework'
  | 'ok'
  | string;
export type TaskStatus = 'pending' | 'in_progress' | 'done' | string;

export interface BacklogStory {
  story_id: string;
  title: string;
  status: StoryStatus;
  priority?: number | string | null;
  points?: number | null;
  iteration?: number | null;
  created?: string | null;
  completed?: string | null;
  [key: string]: unknown;
}

export interface StoryBoardEntry {
  from: string;
  to?: string;
  action?: string;
  output?: string;
  status?: BoardEntryStatus;
  note?: string | null;
  timestamp: string;
}

export interface StoryTaskItem {
  task_id: string | number;
  name?: string;
  status: TaskStatus;
}

export interface StoryDetailData {
  story_id: string;
  title?: string;
  points?: number | null;
  iteration?: number | null;
  status?: StoryStatus;
  board: StoryBoardEntry[];
  tasks?: StoryTaskItem[];
}

export interface InsightItem {
  id: string;
  theme: string;
  insight: string;
  severity: string;
}

export interface OpportunityItem {
  id: string;
  title: string;
  description: string;
  impact: string;
}

export interface InsightsData {
  raw: Array<{ id: string }>;
  findings: Array<{ id: string }>;
  insights: InsightItem[];
  opportunities: OpportunityItem[];
}

export type AgentColors = Record<string, string>;

declare global {
  interface Window {
    BACKLOG_DATA: BacklogStory[];
    STORIES_DATA: StoryDetailData[];
    AGENT_COLORS: AgentColors;
    INSIGHTS_DATA: InsightsData;
  }
}

export {};
