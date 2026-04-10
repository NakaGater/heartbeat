// core/templates/dashboard.html の renderInsights (~line 1441-1486) を React に移植。
// UCD 4層構造 (Raw -> Findings -> Insights -> Opportunities) のサマリーバッジと、
// severity='high' の主要インサイト (最大5件) および impact='high' の主要改善機会 (最大3件) を描画する。
// タスク8で types.ts が導入されるまで、形状はローカルに最小宣言する。

export interface InsightsRawLike {
  id: string;
}

export interface InsightsFindingLike {
  id: string;
}

export interface InsightsItemLike {
  id: string;
  theme: string;
  insight: string;
  severity: string;
}

export interface InsightsOpportunityLike {
  id: string;
  title: string;
  description: string;
  impact: string;
}

export interface InsightsDataLike {
  raw: InsightsRawLike[];
  findings: InsightsFindingLike[];
  insights: InsightsItemLike[];
  opportunities: InsightsOpportunityLike[];
}

interface InsightsPanelProps {
  data: InsightsDataLike | null | undefined;
}

const badgeStyle: React.CSSProperties = {
  display: 'inline-block',
  padding: '4px 10px',
  background: 'var(--bg-card)',
  borderRadius: '16px',
  fontSize: '0.8rem',
};

const arrowStyle: React.CSSProperties = {
  fontSize: '0.7rem',
  color: 'var(--text-muted)',
  margin: '0 6px',
};

const sectionTitleStyle: React.CSSProperties = {
  fontSize: '0.75rem',
  fontWeight: 600,
  color: 'var(--text-muted)',
  marginBottom: '6px',
};

const itemStyle: React.CSSProperties = {
  marginBottom: '6px',
  fontSize: '0.8rem',
};

const severityBadgeStyle: React.CSSProperties = {
  display: 'inline-block',
  padding: '2px 6px',
  borderRadius: '4px',
  fontSize: '0.65rem',
  fontWeight: 600,
  color: '#ef4444',
};

const impactBadgeStyle: React.CSSProperties = {
  display: 'inline-block',
  padding: '2px 6px',
  borderRadius: '4px',
  fontSize: '0.65rem',
  fontWeight: 600,
  color: '#10b981',
};

export function InsightsPanel({ data }: InsightsPanelProps) {
  const isEmpty =
    !data ||
    (data.raw.length === 0 &&
      data.findings.length === 0 &&
      data.insights.length === 0 &&
      data.opportunities.length === 0);

  if (isEmpty) {
    return (
      <div className="bento-card card-insights">
        <div
          id="insights-panel"
          style={{
            fontSize: '0.8rem',
            color: 'var(--text-muted)',
            textAlign: 'center',
            padding: '16px',
          }}
        >
          データなし
        </div>
      </div>
    );
  }

  const highInsights = data.insights
    .filter((i) => i.severity === 'high')
    .slice(0, 5);
  const highOpps = data.opportunities
    .filter((o) => o.impact === 'high')
    .slice(0, 3);

  return (
    <div className="bento-card card-insights">
      <div id="insights-panel">
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            flexWrap: 'wrap',
            gap: '4px',
            marginBottom: '12px',
          }}
        >
          <span style={badgeStyle}>Raw: {data.raw.length}</span>
          <span style={arrowStyle}>{'\u2192'}</span>
          <span style={badgeStyle}>Findings: {data.findings.length}</span>
          <span style={arrowStyle}>{'\u2192'}</span>
          <span style={badgeStyle}>Insights: {data.insights.length}</span>
          <span style={arrowStyle}>{'\u2192'}</span>
          <span style={badgeStyle}>
            Opportunities: {data.opportunities.length}
          </span>
        </div>

        {highInsights.length > 0 && (
          <div style={{ marginBottom: '12px' }}>
            <div style={sectionTitleStyle}>主要インサイト</div>
            {highInsights.map((item) => (
              <div key={`ins-${item.id}`} style={itemStyle}>
                <strong>{item.theme}</strong> {'\u2014 '}
                {item.insight} <span style={severityBadgeStyle}>high</span>
              </div>
            ))}
          </div>
        )}

        {highOpps.length > 0 && (
          <div>
            <div style={sectionTitleStyle}>主要な改善機会</div>
            {highOpps.map((item) => (
              <div key={`opp-${item.id}`} style={itemStyle}>
                <strong>{item.title}</strong> {'\u2014 '}
                {item.description} <span style={impactBadgeStyle}>high</span>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
