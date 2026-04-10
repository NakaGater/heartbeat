// core/templates/dashboard.html の renderMessages (~line 1415-1438) を React に移植。
// 選択中ストーリーの board エントリを timestamp 昇順でソートし、
// エージェント別カラーのチャットバブル (.msg-bubble) として描画する。
// タスク8で types.ts が導入されるまで、形状はローカルに最小宣言する。
import { useMemo } from 'react';

export interface BoardEntryLike {
  from: string;
  to?: string;
  action?: string;
  note?: string;
  status?: string;
  timestamp: string;
}

export interface StoryWithBoardLike {
  story_id: string;
  title?: string;
  board: BoardEntryLike[];
}

export type AgentColorMap = Record<string, string>;

interface AgentMessagesProps {
  stories: StoryWithBoardLike[];
  agentColors: AgentColorMap;
  selectedStoryId: string;
}

// dashboard.html ~line 993-998 と同じフォーマッタ
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

export function AgentMessages({
  stories,
  agentColors,
  selectedStoryId,
}: AgentMessagesProps) {
  const selectedStory = useMemo(
    () => stories.find((s) => s.story_id === selectedStoryId) ?? stories[0],
    [stories, selectedStoryId],
  );

  const sortedEntries = useMemo(() => {
    if (!selectedStory || !selectedStory.board || selectedStory.board.length === 0) {
      return [];
    }
    return selectedStory.board
      .slice()
      .sort(
        (a, b) =>
          new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime(),
      );
  }, [selectedStory]);

  const agentColor = (name: string): string =>
    agentColors[name] || 'var(--text-muted)';

  if (sortedEntries.length === 0) {
    return (
      <div className="bento-card card-messages">
        <div
          id="agent-messages"
          style={{
            fontSize: '0.8rem',
            color: 'var(--text-muted)',
            padding: '16px',
            textAlign: 'center',
          }}
        >
          No messages
        </div>
      </div>
    );
  }

  return (
    <div className="bento-card card-messages">
      <div id="agent-messages">
        {sortedEntries.map((e, idx) => {
          const isHuman = e.from === 'human';
          const isAlert = e.status === 'blocked' || e.status === 'rework';
          return (
            <div
              key={`msg-${idx}-${e.timestamp}`}
              className={`msg-row${isHuman ? ' human' : ''}`}
            >
              <div className={`msg-bubble${isAlert ? ' alert' : ''}`}>
                <div className="msg-agent" style={{ color: agentColor(e.from) }}>
                  {e.from}
                </div>
                {e.action && (
                  <div className="msg-action">
                    {e.action}
                    {e.to ? ` \u2192 ${e.to}` : ''}
                  </div>
                )}
                {e.note && <div className="msg-note">{e.note}</div>}
                <div className="msg-time">{formatTime(e.timestamp)}</div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
