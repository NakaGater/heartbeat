import { HeroMetrics } from './components/HeroMetrics';
import { BacklogBoard } from './components/BacklogBoard';
import { VelocityChart } from './components/VelocityChart';
import { StoryDetail } from './components/StoryDetail';
import { AgentMessages } from './components/AgentMessages';
import { InsightsPanel } from './components/InsightsPanel';
import { Sidebar } from './components/Sidebar';

export function App() {
  return (
    <>
      <Sidebar />
      <div id="app" className="bento-grid">
        <HeroMetrics />
        <div className="bento-card card-backlog-velocity">
          <div className="card-split">
            <BacklogBoard />
            <VelocityChart />
          </div>
        </div>
        <StoryDetail />
        <AgentMessages />
        <InsightsPanel />
      </div>
    </>
  );
}
