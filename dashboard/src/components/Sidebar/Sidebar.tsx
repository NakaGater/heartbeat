import { useState } from 'react';

// Sidebar: 画面左端に固定配置されるナビゲーション。
// design.md「コンポーネント仕様」: position: fixed; left: 0; width: 48px。
// core/templates/dashboard.html ~line 884-891 の静的構造と
// 1591-1608 の initSidebar() 関数ロジックを React に移植する。
// <nav> 要素で暗黙の navigation ロールを付与する (design.md「アクセシビリティ」)。

interface NavItem {
  section: string;
  label: string;
  icon: string;
}

// dashboard.html ~line 884-891 の順序・data-section・絵文字を忠実に踏襲する。
const NAV_ITEMS: NavItem[] = [
  { section: 'hero-metrics', label: 'Metrics', icon: '\u{1f4ca}' },
  { section: 'backlog-board', label: 'Backlog', icon: '\u{1f4cb}' },
  { section: 'velocity-chart', label: 'Velocity', icon: '\u{1f4c8}' },
  { section: 'gantt-chart', label: 'Story', icon: '\u{1f504}' },
  { section: 'agent-messages', label: 'Messages', icon: '\u{1f4ac}' },
  { section: 'insights-panel', label: 'Insights', icon: '\u{1f4a1}' },
];

export function Sidebar() {
  // initSidebar() は最初のアイコンを active として描画していたため同じ初期値を維持する。
  const [activeSection, setActiveSection] = useState<string>(NAV_ITEMS[0].section);

  const handleClick = (section: string) => {
    const target = document.getElementById(section);
    if (target) {
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      setActiveSection(section);
    }
  };

  return (
    <nav className="sidebar">
      {NAV_ITEMS.map((item) => {
        const isActive = item.section === activeSection;
        const className = isActive ? 'sidebar-icon active' : 'sidebar-icon';
        return (
          <button
            key={item.section}
            type="button"
            className={className}
            data-section={item.section}
            aria-label={item.label}
            title={item.label}
            onClick={() => handleClick(item.section)}
          >
            {item.icon}
          </button>
        );
      })}
    </nav>
  );
}
