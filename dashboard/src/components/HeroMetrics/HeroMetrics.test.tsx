import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { HeroMetrics } from './HeroMetrics';

// Minimal backlog story shape for this test. A project-wide types.ts module
// will be introduced in task 8 (App.tsx integration); keeping the shape local
// avoids premature coupling to that not-yet-existing module.
interface BacklogStoryLike {
  story_id: string;
  title: string;
  status: 'draft' | 'ready' | 'in_progress' | 'done';
  points?: number | null;
  iteration?: number | null;
}

describe('HeroMetrics', () => {
  const sampleBacklog: BacklogStoryLike[] = [
    { story_id: '0001', title: 'Story A', status: 'done', points: 3, iteration: 1 },
    { story_id: '0002', title: 'Story B', status: 'in_progress', points: 2, iteration: 1 },
    { story_id: '0003', title: 'Story C', status: 'ready', points: 5, iteration: 1 },
    { story_id: '0004', title: 'Story D', status: 'draft', points: 1, iteration: 1 },
  ];

  it('when rendered with backlog data, should display 4 metric cards', () => {
    render(<HeroMetrics backlog={sampleBacklog} />);
    const cards = screen.getAllByRole('article');
    expect(cards).toHaveLength(4);
  });
});
