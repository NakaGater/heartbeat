import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { InsightsPanel } from './InsightsPanel';

// Minimal insights data shape for this test. A project-wide types.ts module
// will be introduced in task 8 (App.tsx integration); keeping the shape local
// avoids premature coupling to that not-yet-existing module.
interface InsightsDataLike {
  raw: Array<{ id: string }>;
  findings: Array<{ id: string }>;
  insights: Array<{ id: string; theme: string; insight: string; severity: string }>;
  opportunities: Array<{ id: string; title: string; description: string; impact: string }>;
}

describe('InsightsPanel', () => {
  const sampleInsights: InsightsDataLike = {
    raw: [{ id: 'r1' }, { id: 'r2' }],
    findings: [{ id: 'f1' }],
    insights: [
      { id: 'i1', theme: 'Onboarding', insight: 'Users struggle with first login', severity: 'high' },
    ],
    opportunities: [
      { id: 'o1', title: 'Improve onboarding', description: 'Add guided tour', impact: 'high' },
    ],
  };

  it('when rendered with sample insights data, should display all 4 UCD layer labels', () => {
    render(<InsightsPanel data={sampleInsights} />);
    expect(screen.getByText(/Raw:/)).toBeInTheDocument();
    expect(screen.getByText(/Findings:/)).toBeInTheDocument();
    expect(screen.getByText(/Insights:/)).toBeInTheDocument();
    expect(screen.getByText(/Opportunities:/)).toBeInTheDocument();
  });
});
