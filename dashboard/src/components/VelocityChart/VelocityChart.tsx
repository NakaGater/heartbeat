// core/templates/dashboard.html の renderVelocity (~line 1065-1166) を React に移植。
// タスク8でプロジェクト全体の types.ts が導入されるまで、HeroMetrics と同様に
// 最小形状をローカル宣言し、早すぎる結合を避ける。
export interface BacklogStoryLike {
  story_id: string;
  title: string;
  status: 'draft' | 'ready' | 'in_progress' | 'done';
  points?: number | null;
  iteration?: number | null;
  completed?: string | null;
}

interface VelocityChartProps {
  backlog: BacklogStoryLike[];
}

// ── ISO 8601 Week Number Helper ── (dashboard.html ~line 1052-1062)
function getISOWeekNumber(dateStr: string | null | undefined): string | null {
  if (dateStr == null) return null;
  const s = String(dateStr);
  const d = new Date(s.indexOf('T') !== -1 ? s : s + 'T00:00:00Z');
  if (isNaN(d.getTime())) return null;
  d.setUTCHours(0, 0, 0, 0);
  const dayOfWeek = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - dayOfWeek);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  const weekNo = Math.ceil((((d.getTime() - yearStart.getTime()) / 86400000) + 1) / 7);
  return d.getUTCFullYear() + '-W' + String(weekNo).padStart(2, '0');
}

const MIN_ENTRIES = 5;
const BAR_W = 48;
const GAP = 20;
const PAD_L = 40;
const PAD_R = 16;
const PAD_T = 16;
const PAD_B = 32;
const CHART_H_TOTAL = 280;

interface VelocityData {
  labels: string[];
  values: number[];
}

function computeVelocity(backlog: BacklogStoryLike[]): VelocityData | null {
  // iteration 優先集計
  const iterMap: Record<number, number> = {};
  for (const item of backlog) {
    if (item.iteration != null && item.status === 'done' && item.points != null) {
      const k = item.iteration;
      iterMap[k] = (iterMap[k] || 0) + (Number(item.points) || 0);
    }
  }
  const iters = Object.keys(iterMap).map(Number).sort((a, b) => a - b);

  let labels: string[] = [];
  let values: number[] = [];

  if (iters.length > 0) {
    labels = iters.map((i) => 'Iter ' + i);
    values = iters.map((i) => iterMap[i]);
  } else {
    // フォールバック: done+points+completed 有りストーリーを ISO 週でグルーピング
    const doneWithPoints = backlog.filter(
      (item) => item.status === 'done' && item.points != null && item.completed != null,
    );
    if (doneWithPoints.length === 0) return null;

    const weekMap: Record<string, number> = {};
    for (const item of doneWithPoints) {
      const wn = getISOWeekNumber(item.completed);
      if (wn != null) {
        weekMap[wn] = (weekMap[wn] || 0) + (Number(item.points) || 0);
      }
    }
    const weeks = Object.keys(weekMap).sort();
    if (weeks.length === 0) return null;

    labels = weeks;
    values = weeks.map((w) => weekMap[w]);
  }

  // MIN_ENTRIES 未満ならゼロ値プレースホルダでパディング
  if (labels.length < MIN_ENTRIES) {
    const padCount = MIN_ENTRIES - labels.length;
    const padLabels: string[] = [];
    const padValues: number[] = [];
    const firstLabel = labels.length > 0 ? labels[0] : null;
    for (let pi = padCount; pi >= 1; pi--) {
      if (firstLabel && /^\d{4}-W\d{2}$/.test(firstLabel)) {
        const parts = firstLabel.match(/^(\d{4})-W(\d{2})$/)!;
        let yr = parseInt(parts[1], 10);
        let wk = parseInt(parts[2], 10) - pi;
        while (wk < 1) {
          yr -= 1;
          wk += 52;
        }
        padLabels.push(yr + '-W' + String(wk).padStart(2, '0'));
      } else {
        padLabels.push('W' + String(pi).padStart(2, '0'));
      }
      padValues.push(0);
    }
    labels = padLabels.concat(labels);
    values = padValues.concat(values);
  }

  return { labels, values };
}

export function VelocityChart({ backlog }: VelocityChartProps) {
  const data = computeVelocity(backlog);

  if (data === null) {
    return (
      <div className="velocity-chart">
        <div className="chart-fallback">データ収集中…</div>
      </div>
    );
  }

  const { labels, values } = data;
  const maxVal = Math.max.apply(null, values);
  const nonZero = values.filter((v) => v > 0);
  const avg =
    nonZero.length > 0 ? nonZero.reduce((a, b) => a + b, 0) / nonZero.length : 0;

  const w = PAD_L + labels.length * (BAR_W + GAP) + PAD_R;
  const h = CHART_H_TOTAL;
  const chartH = h - PAD_T - PAD_B;
  // 10% headroom
  const scale = maxVal > 0 ? chartH / (maxVal * 1.1) : 1;
  const avgY = h - PAD_B - avg * scale;

  return (
    <div className="velocity-chart">
      <svg viewBox={`0 0 ${w} ${h}`} xmlns="http://www.w3.org/2000/svg">
        {/* Y-axis */}
        <line
          x1={PAD_L}
          y1={PAD_T}
          x2={PAD_L}
          y2={h - PAD_B}
          stroke="var(--border)"
          strokeWidth="1"
        />
        {/* X-axis */}
        <line
          x1={PAD_L}
          y1={h - PAD_B}
          x2={w - PAD_R}
          y2={h - PAD_B}
          stroke="var(--border)"
          strokeWidth="1"
        />
        {labels.map((label, i) => {
          const val = values[i];
          const barH = val * scale;
          const x = PAD_L + i * (BAR_W + GAP) + GAP / 2;
          const y = h - PAD_B - barH;
          return (
            <g key={label + '-' + i}>
              <rect
                x={x}
                y={y}
                width={BAR_W}
                height={barH}
                fill="var(--accent)"
                rx="3"
              />
              <text
                x={x + BAR_W / 2}
                y={y - 4}
                textAnchor="middle"
                fontSize="10"
                fill="var(--text)"
              >
                {val}
              </text>
              <text
                x={x + BAR_W / 2}
                y={h - PAD_B + 14}
                textAnchor="middle"
                fontSize="10"
                fill="var(--text-muted)"
              >
                {label}
              </text>
            </g>
          );
        })}
        {/* Average line */}
        <line
          x1={PAD_L}
          y1={avgY}
          x2={w - PAD_R}
          y2={avgY}
          stroke="var(--red-border)"
          strokeWidth="1"
          strokeDasharray="4,3"
        />
        <text
          x={w - PAD_R - 2}
          y={avgY - 4}
          textAnchor="end"
          fontSize="9"
          fill="var(--red-border)"
        >
          avg {avg.toFixed(1)}
        </text>
      </svg>
    </div>
  );
}
