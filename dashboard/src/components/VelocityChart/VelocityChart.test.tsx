import { render } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { VelocityChart } from './VelocityChart';

// 最小 backlog 形状。プロジェクト全体の types.ts はタスク8で導入予定のため、
// HeroMetrics.test.tsx と同じくローカル宣言でカップリングを避ける。
interface BacklogStoryLike {
  story_id: string;
  title: string;
  status: 'draft' | 'ready' | 'in_progress' | 'done';
  points?: number | null;
  iteration?: number | null;
}

describe('VelocityChart', () => {
  // iteration ごとに done + points を集計してバーを描画する
  // (design.md §6.2-3, renderVelocity ~line 1065-1166 参照)
  const sampleBacklog: BacklogStoryLike[] = [
    { story_id: '0001', title: 'Story A', status: 'done', points: 5, iteration: 1 },
    { story_id: '0002', title: 'Story B', status: 'done', points: 8, iteration: 2 },
  ];

  it('when rendered with weekly velocity data, should render an SVG with <rect> bars', () => {
    const { container } = render(<VelocityChart backlog={sampleBacklog} />);
    const svg = container.querySelector('svg');
    expect(svg).not.toBeNull();
    const rects = container.querySelectorAll('svg rect');
    expect(rects.length).toBeGreaterThan(0);
  });
});
