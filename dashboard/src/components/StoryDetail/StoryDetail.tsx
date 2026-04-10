// core/templates/dashboard.html の renderGantt (~line 1199-1396) および
// renderTasks (~line 1398-1412) を React に移植。
// タスク8で types.ts が導入されるまで、形状はローカルに最小宣言する。
import { useMemo, useState } from 'react';

export interface BoardEntryLike {
  from: string;
  to?: string;
  action?: string;
  status?: string;
  timestamp: string;
}

export interface StoryDetailData {
  story_id: string;
  title?: string;
  board: BoardEntryLike[];
  tasks?: Array<{ task_id: string | number; name?: string; status: string }>;
}

export type AgentColorMap = Record<string, string>;

interface StoryDetailProps {
  stories: StoryDetailData[];
  agentColors: AgentColorMap;
  // 任意: App.tsx が選択状態を持って AgentMessages と共有する場合に渡す。
  // 渡されなかった場合は従来どおり内部 useState にフォールバックする
  // (既存テストの後方互換性を維持)。
  selectedStoryId?: string;
  onSelectStory?: (storyId: string) => void;
}

// dashboard.html ~line 993-998
function formatTime(ts: number | string | Date): string {
  if (ts == null) return 'N/A';
  const d = new Date(ts as string);
  if (d.getTime() !== d.getTime()) return 'N/A';
  return d.toLocaleString(undefined, {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

interface Segment {
  start: number;
  end: number;
  offsetX: number;
  scale: number;
}

interface GanttModel {
  empty: boolean;
  entries: BoardEntryLike[];
  agents: string[];
  segments: Segment[];
  gaps: Array<{ start: number; end: number }>;
  tMin: number;
  tMax: number;
  padL: number;
  padR: number;
  padT: number;
  padB: number;
  rowH: number;
  barH: number;
  chartW: number;
  w: number;
  h: number;
  mapX: (ts: number) => number;
}

// renderGantt のジオメトリ/圧縮計算部分を純粋関数として切り出し、
// テスト容易性と描画の分離を図る。
function buildGanttModel(
  story: StoryDetailData | undefined,
  agentColors: AgentColorMap,
): GanttModel | null {
  if (!story || !story.board || story.board.length === 0) return null;
  // entries は後段で timestamp を上書きするため、元配列を破壊しないよう複製する。
  const entries: BoardEntryLike[] = story.board
    .filter((e) => e.from)
    .map((e) => ({ ...e }));
  if (entries.length === 0) return null;

  // NaN ガード付きで既知タイムスタンプから最後の値を取得し、
  // 欠損/不正値は lastKnown でバックフィルする。
  const withTs = entries.filter((e) => {
    const t = new Date(e.timestamp).getTime();
    return !!e.timestamp && t === t;
  });
  withTs.sort(
    (a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime(),
  );
  if (withTs.length > 0) {
    const lastKnown = withTs[withTs.length - 1].timestamp;
    entries.forEach((e) => {
      const ts = new Date(e.timestamp).getTime();
      if (!e.timestamp || ts !== ts) e.timestamp = lastKnown;
    });
  } else {
    const now = new Date();
    entries.forEach((e, idx) => {
      e.timestamp = new Date(
        now.getTime() - (entries.length - 1 - idx) * 600000,
      ).toISOString();
    });
  }

  // 表示順にソート（バーの next-entry 終端計算が正しく動くように）
  entries.sort(
    (a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime(),
  );

  const agents = Object.keys(agentColors).filter((a) => a !== 'human');

  const tMin = new Date(entries[0].timestamp).getTime();
  let tMax = new Date(entries[entries.length - 1].timestamp).getTime();
  if (tMax <= tMin) tMax = tMin + 3600000; // 最低 1 時間のスパンを確保

  const padL = 110;
  const padR = 16;
  const padT = 24;
  const padB = 32;
  const rowH = 20;
  const barH = 18;
  const chartW = 600;
  const w = padL + chartW + padR;
  const h = padT + agents.length * rowH + padB;
  const tScale = chartW / (tMax - tMin);

  // ── Gap detection (0065-T1) ──
  const GAP_THRESHOLD_RATIO = 0.2;
  const GAP_WIDTH_RATIO = 0.05;
  const totalRange = tMax - tMin;
  const gapThreshold = totalRange * GAP_THRESHOLD_RATIO;
  const timestamps = entries
    .map((e) => new Date(e.timestamp).getTime())
    .slice()
    .sort((a, b) => a - b);

  const gaps: Array<{ start: number; end: number }> = [];
  let totalGapSize = 0;
  for (let gi = 1; gi < timestamps.length; gi++) {
    const delta = timestamps[gi] - timestamps[gi - 1];
    if (delta >= gapThreshold) {
      gaps.push({ start: timestamps[gi - 1], end: timestamps[gi] });
      totalGapSize += delta;
    }
  }

  const segments: Segment[] = [];
  if (gaps.length === 0) {
    segments.push({ start: tMin, end: tMax, offsetX: 0, scale: tScale });
  } else {
    const gapCompressedWidth = chartW * GAP_WIDTH_RATIO;
    const activityWidth = chartW - gaps.length * gapCompressedWidth;
    const totalActivity = totalRange - totalGapSize;
    const activityScale =
      totalActivity > 0 ? activityWidth / totalActivity : tScale;

    let segStart = tMin;
    let currentOffset = 0;
    for (let gk = 0; gk < gaps.length; gk++) {
      const gap = gaps[gk];
      if (gap.start > segStart) {
        segments.push({
          start: segStart,
          end: gap.start,
          offsetX: currentOffset,
          scale: activityScale,
        });
        currentOffset += (gap.start - segStart) * activityScale;
      }
      currentOffset += gapCompressedWidth;
      segStart = gap.end;
    }
    if (segStart < tMax) {
      segments.push({
        start: segStart,
        end: tMax,
        offsetX: currentOffset,
        scale: activityScale,
      });
    }
    if (segments.length === 0) {
      segments.push({ start: tMin, end: tMax, offsetX: 0, scale: tScale });
    }
  }

  // ── mapX: 圧縮座標マッピング (0065-T2) ──
  function mapX(ts: number): number {
    for (let si = 0; si < segments.length; si++) {
      const seg = segments[si];
      if (ts <= seg.end || si === segments.length - 1) {
        const clamped = Math.max(ts, seg.start);
        return seg.offsetX + (clamped - seg.start) * seg.scale;
      }
    }
    return 0;
  }

  return {
    empty: false,
    entries,
    agents,
    segments,
    gaps,
    tMin,
    tMax,
    padL,
    padR,
    padT,
    padB,
    rowH,
    barH,
    chartW,
    w,
    h,
    mapX,
  };
}

const ZIGZAG_AMP = 3;
const ZIGZAG_PERIOD = 6;
const TOTAL_TICKS = 5;

const TASK_ICONS: Record<string, string> = {
  done: '\u2705',
  in_progress: '\uD83D\uDD04',
  pending: '\u2B1C',
};

export function StoryDetail({
  stories,
  agentColors,
  selectedStoryId: selectedStoryIdProp,
  onSelectStory,
}: StoryDetailProps) {
  // in_progress ストーリーがあれば初期選択。なければ先頭。
  const initialId = useMemo(() => {
    const inProgress = stories.find(
      (s) => (s as unknown as { status?: string }).status === 'in_progress',
    );
    if (inProgress) return inProgress.story_id;
    return stories.length > 0 ? stories[0].story_id : '';
  }, [stories]);

  const [internalId, setInternalId] = useState<string>(initialId);
  const isControlled = selectedStoryIdProp !== undefined;
  const selectedStoryId = isControlled ? selectedStoryIdProp! : internalId;
  const setSelectedStoryId = (id: string) => {
    if (!isControlled) setInternalId(id);
    if (onSelectStory) onSelectStory(id);
  };

  const selectedStory = useMemo(
    () => stories.find((s) => s.story_id === selectedStoryId) ?? stories[0],
    [stories, selectedStoryId],
  );

  const model = useMemo(
    () => buildGanttModel(selectedStory, agentColors),
    [selectedStory, agentColors],
  );

  const agentColor = (name: string): string =>
    agentColors[name] || 'var(--text-muted)';

  // ── Gantt SVG ──
  const renderGantt = () => {
    if (!model) {
      return <div className="chart-fallback">No board data</div>;
    }
    const {
      entries,
      agents,
      segments,
      gaps,
      tMax,
      padL,
      padT,
      padB,
      rowH,
      barH,
      w,
      h,
      mapX,
    } = model;

    // Tick 配置: セグメント期間に比例して割当
    let totalSegDuration = 0;
    for (const s of segments) totalSegDuration += s.end - s.start;
    if (totalSegDuration <= 0) totalSegDuration = 1;

    const ticks: Array<{ x: number; label: string; key: string }> = [];
    let ticksPlaced = 0;
    for (let si = 0; si < segments.length; si++) {
      const seg = segments[si];
      const segDuration = seg.end - seg.start;
      const segTicks =
        si === segments.length - 1
          ? TOTAL_TICKS - ticksPlaced
          : Math.round((segDuration / totalSegDuration) * TOTAL_TICKS);
      for (let st = 0; st <= segTicks; st++) {
        const frac = segTicks > 0 ? st / segTicks : 0;
        const tsVal = seg.start + frac * segDuration;
        const tx = padL + mapX(tsVal);
        ticks.push({
          x: tx,
          label: formatTime(new Date(tsVal)),
          key: `tick-${si}-${st}`,
        });
      }
      ticksPlaced += segTicks;
    }

    // ジグザグ break path
    const zigzagTop = padT;
    const zigzagBot = h - padB;
    const gapPaths = gaps.map((g, gi) => {
      const gapCenterX = padL + (mapX(g.start) + mapX(g.end)) / 2;
      let d = `M ${gapCenterX},${zigzagTop}`;
      for (let zy = zigzagTop; zy < zigzagBot; zy += ZIGZAG_PERIOD) {
        d += ` L ${gapCenterX + ZIGZAG_AMP},${zy + ZIGZAG_PERIOD / 2}`;
        d += ` L ${gapCenterX - ZIGZAG_AMP},${Math.min(zy + ZIGZAG_PERIOD, zigzagBot)}`;
      }
      return <path key={`gap-${gi}`} className="gap-break" d={d} fill="none" stroke="var(--text-muted)" strokeWidth="1" role="presentation" />;
    });

    // Bars
    const bars = entries.map((e, ei) => {
      const agentIdx = agents.indexOf(e.from);
      if (agentIdx < 0) return null;
      const start = new Date(e.timestamp).getTime();
      let end = tMax;
      if (ei + 1 < entries.length) {
        end = new Date(entries[ei + 1].timestamp).getTime();
      }
      const x = padL + mapX(start);
      const bw = Math.max(mapX(end) - mapX(start), 2);
      const by = padT + agentIdx * rowH + (rowH - barH) / 2;
      const isRework = e.status === 'rework';
      return (
        <g key={`bar-${ei}`}>
          <rect
            x={x}
            y={by}
            width={bw}
            height={barH}
            fill={agentColor(e.from)}
            rx="1"
            opacity="0.8"
            {...(isRework
              ? {
                  stroke: agentColor(e.from),
                  strokeDasharray: '4,2',
                  fillOpacity: 0.4,
                }
              : {})}
          />
          <title>{`${e.from} / ${e.action || ''} / ${e.timestamp || ''}`}</title>
        </g>
      );
    });

    return (
      <svg
        viewBox={`0 0 ${w} ${h}`}
        xmlns="http://www.w3.org/2000/svg"
        style={{ minWidth: `${w}px` }}
      >
        {agents.map((agent, i) => {
          const y = padT + i * rowH;
          return (
            <g key={`row-${agent}`}>
              {i % 2 === 0 && (
                <rect
                  x={0}
                  y={y}
                  width={w}
                  height={rowH}
                  fill="var(--bg-card)"
                  opacity={0.3}
                />
              )}
              <text
                x={padL - 8}
                y={y + rowH / 2 + 4}
                textAnchor="end"
                fontSize="11"
                fill={agentColor(agent)}
              >
                {agent}
              </text>
            </g>
          );
        })}
        {ticks.map((t) => (
          <g key={t.key}>
            <text
              x={t.x}
              y={h - 8}
              textAnchor="middle"
              fontSize="9"
              fill="var(--text-muted)"
            >
              {t.label}
            </text>
            <line
              x1={t.x}
              y1={padT}
              x2={t.x}
              y2={h - padB}
              stroke="var(--border)"
              strokeWidth="0.5"
              opacity="0.5"
            />
          </g>
        ))}
        {gapPaths}
        {bars}
      </svg>
    );
  };

  // ── Task list ──
  const renderTasks = () => {
    if (!selectedStory || !selectedStory.tasks || selectedStory.tasks.length === 0) {
      return (
        <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
          No tasks
        </span>
      );
    }
    return (
      <>
        {selectedStory.tasks.map((t) => {
          const icon = TASK_ICONS[t.status] || TASK_ICONS.pending;
          return (
            <span key={String(t.task_id)} className="task-chip">
              {icon} {t.name || String(t.task_id)}
            </span>
          );
        })}
      </>
    );
  };

  return (
    <div className="bento-card card-story">
      <div className="card-header">
        <select
          id="story-select"
          value={selectedStoryId}
          onChange={(e) => setSelectedStoryId(e.target.value)}
        >
          {stories.map((s) => (
            <option key={s.story_id} value={s.story_id}>
              {s.story_id}
            </option>
          ))}
        </select>
      </div>
      <div id="gantt-chart" className="gantt-chart">
        {renderGantt()}
      </div>
      <div id="task-list" className="task-list">
        {renderTasks()}
      </div>
    </div>
  );
}
