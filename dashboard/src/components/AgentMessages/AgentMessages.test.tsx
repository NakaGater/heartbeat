import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { AgentMessages } from './AgentMessages';

// renderMessages() (core/templates/dashboard.html ~L1415-1438) が
// 各ボードエントリを `.msg-bubble` のチャットバブルとして描画することを検証する。
// プロジェクト共通の types.ts はタスク 8 で導入予定のため、
// 必要最小限の形状をテスト内ローカルで定義する。
interface BoardEntryLike {
  from: string;
  to?: string;
  action?: string;
  note?: string;
  status?: string;
  timestamp: string;
}

interface StoryWithBoardLike {
  story_id: string;
  title: string;
  board: BoardEntryLike[];
}

describe('AgentMessages', () => {
  const sampleStories: StoryWithBoardLike[] = [
    {
      story_id: '0001',
      title: 'Story A',
      board: [
        {
          from: 'designer',
          to: 'architect',
          action: 'handoff',
          note: '設計レビュー依頼',
          timestamp: '2026-04-09T10:00:00Z',
        },
        {
          from: 'architect',
          to: 'tester',
          action: 'handoff',
          note: 'タスク分解完了',
          timestamp: '2026-04-09T10:05:00Z',
        },
        {
          from: 'tester',
          to: 'implementer',
          action: 'make_green',
          note: 'Red 確認済み',
          timestamp: '2026-04-09T10:10:00Z',
        },
      ],
    },
  ];

  const agentColors: Record<string, string> = {
    designer: '#EC4899',
    architect: '#8B5CF6',
    tester: '#F59E0B',
    implementer: '#10B981',
  };

  it('when rendered with sample messages, should display a chat bubble for each entry', () => {
    const { container } = render(
      <AgentMessages
        stories={sampleStories}
        agentColors={agentColors}
        selectedStoryId="0001"
      />
    );
    const bubbles = container.querySelectorAll('.msg-bubble');
    expect(bubbles).toHaveLength(3);
    expect(screen.getByText('設計レビュー依頼')).toBeInTheDocument();
    expect(screen.getByText('タスク分解完了')).toBeInTheDocument();
    expect(screen.getByText('Red 確認済み')).toBeInTheDocument();
  });
});
