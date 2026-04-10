import { useEffect, useRef, useState } from 'react';

// タスク8でプロジェクト全体の types.ts が導入されるまでのローカル型定義。
// 早すぎる結合を避けるため、テストと同じ最小形状をここでも宣言する。
export interface BacklogStoryLike {
  story_id: string;
  title: string;
  status: 'draft' | 'ready' | 'in_progress' | 'done';
  points?: number | null;
  iteration?: number | null;
}

interface HeroMetricsProps {
  backlog: BacklogStoryLike[];
}

interface MetricDef {
  key: string;
  label: string;
  value: number;
  max: number; // プログレスリング用の分母
  suffix?: string;
}

// core/templates/dashboard.html の元実装に合わせ r=28 を維持する
// （viewBox 36x36 に対しては意図的に大きい値だが、原典の挙動を踏襲）。
const RING_RADIUS = 28;
const RING_CIRCUMFERENCE = 2 * Math.PI * RING_RADIUS;
const ANIMATION_DURATION_MS = 1200;

// dashboard.html の animateCounter と同じ easeOutExpo イージング。
function easeOutExpo(progress: number): number {
  return progress === 1 ? 1 : 1 - Math.pow(2, -10 * progress);
}

function useCountUp(target: number): number {
  const [display, setDisplay] = useState(0);
  const rafRef = useRef<number | null>(null);

  useEffect(() => {
    const reducedMotion =
      typeof window !== 'undefined' &&
      typeof window.matchMedia === 'function' &&
      window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    if (reducedMotion || ANIMATION_DURATION_MS === 0) {
      setDisplay(target);
      return;
    }

    const start = performance.now();
    const step = (now: number) => {
      const elapsed = now - start;
      const progress = Math.min(elapsed / ANIMATION_DURATION_MS, 1);
      const eased = easeOutExpo(progress);
      setDisplay(Math.round(target * eased));
      if (progress < 1) {
        rafRef.current = requestAnimationFrame(step);
      }
    };
    rafRef.current = requestAnimationFrame(step);

    return () => {
      if (rafRef.current !== null) {
        cancelAnimationFrame(rafRef.current);
        rafRef.current = null;
      }
    };
  }, [target]);

  return display;
}

function MetricCard({ metric }: { metric: MetricDef }) {
  const animated = useCountUp(metric.value);
  const ratio = metric.max > 0 ? Math.min(metric.value / metric.max, 1) : 0;
  const dashOffset = RING_CIRCUMFERENCE - ratio * RING_CIRCUMFERENCE;

  return (
    <article className="metric-card metric-card--with-ring" data-metric={metric.key}>
      <div className="metric-ring-wrap">
        <svg className="metric-ring" viewBox="0 0 36 36" aria-hidden="true">
          <circle
            cx="18"
            cy="18"
            r={RING_RADIUS}
            fill="none"
            stroke="var(--border)"
            strokeWidth="2"
          />
          <circle
            className="progress"
            cx="18"
            cy="18"
            r={RING_RADIUS}
            fill="none"
            stroke="var(--accent)"
            strokeWidth="2"
            strokeLinecap="round"
            strokeDasharray={RING_CIRCUMFERENCE}
            strokeDashoffset={dashOffset}
          />
        </svg>
      </div>
      <div className="metric-ring-value">
        <div className="metric-value">
          {animated}
          {metric.suffix ?? ''}
        </div>
        <div className="metric-label">{metric.label}</div>
      </div>
    </article>
  );
}

export function HeroMetrics({ backlog }: HeroMetricsProps) {
  const total = backlog.length;
  let done = 0;
  let inProgress = 0;
  let totalPoints = 0;
  for (const story of backlog) {
    if (story.status === 'done') done += 1;
    if (story.status === 'in_progress') inProgress += 1;
    totalPoints += Number(story.points) || 0;
  }

  const metrics: MetricDef[] = [
    { key: 'completed-stories', label: 'Completed Stories', value: done, max: Math.max(total, 1) },
    { key: 'total-points', label: 'Total Points', value: totalPoints, max: Math.max(totalPoints, 1) },
    { key: 'in-progress', label: 'In Progress', value: inProgress, max: Math.max(total, 1) },
    { key: 'active-agents', label: 'Active Agents', value: inProgress, max: Math.max(total, 1) },
  ];

  return (
    <header className="hero-metrics">
      {metrics.map((metric) => (
        <MetricCard key={metric.key} metric={metric} />
      ))}
    </header>
  );
}
