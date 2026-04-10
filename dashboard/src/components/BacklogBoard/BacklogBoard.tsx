// BacklogBoard: renderBacklog() を React に移植した 4 カラム kanban コンポーネント。
// 元実装: core/templates/dashboard.html renderBacklog() 付近。
// 親 bento-card の内部要素のため、自身は bento-card クラスを持たない。

export interface BacklogStory {
  story_id: string;
  title?: string;
  status?: string;
  points?: number | null;
  iteration?: number | null;
}

interface BacklogBoardProps {
  backlog?: BacklogStory[];
  currentStoryId?: string | null;
}

type ColumnKey = 'draft' | 'ready' | 'in_progress' | 'done';

const COLUMN_ORDER: ColumnKey[] = ['draft', 'ready', 'in_progress', 'done'];
const COLUMN_LABELS: Record<ColumnKey, string> = {
  draft: 'Draft',
  ready: 'Ready',
  in_progress: 'In Progress',
  done: 'Done',
};

export function BacklogBoard({ backlog = [], currentStoryId = null }: BacklogBoardProps) {
  const cols: Record<ColumnKey, BacklogStory[]> = {
    draft: [],
    ready: [],
    in_progress: [],
    done: [],
  };
  backlog.forEach((item) => {
    const s = ((item.status || 'draft').toLowerCase()) as ColumnKey;
    if (cols[s]) cols[s].push(item);
  });

  return (
    <div className="backlog-board" id="backlog-board">
      {COLUMN_ORDER.map((key) => {
        const items = cols[key];
        return (
          <div className="kanban-col" key={key}>
            <div className="kanban-col-header">{COLUMN_LABELS[key]}</div>
            <div className="kanban-col-cards">
              {items.length === 0 ? (
                <div
                  style={{
                    fontSize: '0.7rem',
                    color: 'var(--text-muted)',
                    textAlign: 'center',
                    padding: '8px',
                  }}
                >
                  —
                </div>
              ) : (
                items.map((item) => {
                  const isCurrent = currentStoryId != null && item.story_id === currentStoryId;
                  const className = 'kanban-card' + (isCurrent ? ' current-story' : '');
                  return (
                    <div className={className} key={item.story_id}>
                      <div className="card-title">{item.title || item.story_id}</div>
                      <div className="card-points">
                        {item.points != null ? `${item.points} pts` : '—'}
                      </div>
                    </div>
                  );
                })
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
}
