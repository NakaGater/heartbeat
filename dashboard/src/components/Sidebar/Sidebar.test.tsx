import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { Sidebar } from './Sidebar';

// design.md「完了条件」(Sidebar 行): 6 アイコン、`data-section` 属性、
// click で active 切替 (`scrollIntoView` を `vi.fn()` でスパイ)。
// dashboard.html ~line 884-891 の静的構造より、
// Metrics / Backlog / Velocity / Story / Messages / Insights の 6 ナビゲーション項目が
// 常に描画されることを本テストで検証する (完了条件 1/3)。
describe('Sidebar', () => {
  it('when rendered, should display 6 navigation icons with section labels', () => {
    render(<Sidebar />);
    const expectedLabels = [
      'Metrics',
      'Backlog',
      'Velocity',
      'Story',
      'Messages',
      'Insights',
    ];
    for (const label of expectedLabels) {
      expect(screen.getByLabelText(label)).toBeInTheDocument();
    }
  });
});
