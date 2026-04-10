import { render, screen, within } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { BacklogBoard } from './BacklogBoard';

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

describe('BacklogBoard', () => {
  const sampleBacklog: BacklogStoryLike[] = [
    { story_id: '0001', title: 'Draft Story', status: 'draft', points: 1, iteration: 1 },
    { story_id: '0002', title: 'Ready Story', status: 'ready', points: 2, iteration: 1 },
    { story_id: '0003', title: 'In Progress Story', status: 'in_progress', points: 3, iteration: 1 },
    { story_id: '0004', title: 'Done Story', status: 'done', points: 5, iteration: 1 },
  ];

  it('when rendered with stories of each status, should render 4 columns and place each story in the correct column', () => {
    const { container } = render(<BacklogBoard backlog={sampleBacklog} />);

    // 4 kanban columns exist
    const cols = container.querySelectorAll('.kanban-col');
    expect(cols).toHaveLength(4);

    // Column headers appear in order: Draft, Ready, In Progress, Done
    const headers = container.querySelectorAll('.kanban-col-header');
    expect(headers[0].textContent).toBe('Draft');
    expect(headers[1].textContent).toBe('Ready');
    expect(headers[2].textContent).toBe('In Progress');
    expect(headers[3].textContent).toBe('Done');

    // Each story's title appears inside the column matching its status
    expect(within(cols[0] as HTMLElement).getByText('Draft Story')).toBeInTheDocument();
    expect(within(cols[1] as HTMLElement).getByText('Ready Story')).toBeInTheDocument();
    expect(within(cols[2] as HTMLElement).getByText('In Progress Story')).toBeInTheDocument();
    expect(within(cols[3] as HTMLElement).getByText('Done Story')).toBeInTheDocument();

    // Sanity: the "Draft Story" card is NOT in the Done column
    expect(within(cols[3] as HTMLElement).queryByText('Draft Story')).toBeNull();
    // And screen-wide, the title appears exactly once
    expect(screen.getAllByText('Draft Story')).toHaveLength(1);
  });
});
