import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { StoryDetail } from './StoryDetail';

// Minimal shapes for this test. Shared types.ts module will be introduced
// in task 8 (App.tsx integration); keeping shapes local avoids premature
// coupling to the not-yet-existing module.
interface BoardEntryLike {
  from: string;
  to?: string;
  action?: string;
  status?: string;
  timestamp: string;
}
interface StoryDetailDataLike {
  story_id: string;
  title?: string;
  board: BoardEntryLike[];
  tasks?: Array<{ task_id: string | number; name: string; status: string }>;
}
type AgentColorMapLike = Record<string, string>;

describe('StoryDetail', () => {
  const sampleStories: StoryDetailDataLike[] = [
    {
      story_id: '0001',
      title: 'Story One',
      board: [
        { from: 'designer', to: 'architect', action: 'design', status: 'ok', timestamp: '2026-04-01T10:00:00Z' },
        { from: 'architect', to: 'tester', action: 'plan', status: 'ok', timestamp: '2026-04-01T11:00:00Z' },
        { from: 'tester', to: 'implementer', action: 'make_green', status: 'ok', timestamp: '2026-04-01T12:00:00Z' },
      ],
      tasks: [{ task_id: 1, name: 'Task A', status: 'done' }],
    },
    {
      story_id: '0002',
      title: 'Story Two',
      board: [
        { from: 'designer', to: 'architect', action: 'design', status: 'ok', timestamp: '2026-04-02T10:00:00Z' },
        { from: 'architect', to: 'tester', action: 'plan', status: 'ok', timestamp: '2026-04-02T11:00:00Z' },
      ],
      tasks: [],
    },
  ];

  const agentColors: AgentColorMapLike = {
    human: '#000000',
    designer: '#ff0000',
    architect: '#00ff00',
    tester: '#0000ff',
    implementer: '#ffff00',
  };

  it('when rendered with sample stories, should show a story selector and a gantt SVG chart', () => {
    render(<StoryDetail stories={sampleStories} agentColors={agentColors} />);

    // Story selector: a <select> element (role="combobox") with story options
    const selector = screen.getByRole('combobox');
    expect(selector).toBeInTheDocument();
    expect(selector.tagName).toBe('SELECT');

    // Gantt SVG chart: an <svg> element inside the component
    const svg = document.querySelector('svg');
    expect(svg).not.toBeNull();
  });
});
