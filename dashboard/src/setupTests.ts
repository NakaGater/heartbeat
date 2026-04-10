import '@testing-library/jest-dom';

// reduced-motion 判定: 常に false (フルアニメーション経路をテスト)。
// 個別テストで spy 差し替えにより matches: true 経路も検証できる。
if (!window.matchMedia) {
  window.matchMedia = ((query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: () => {},
    removeListener: () => {},
    addEventListener: () => {},
    removeEventListener: () => {},
    dispatchEvent: () => false,
  })) as unknown as typeof window.matchMedia;
}

// Sidebar の scrollIntoView: jsdom 未実装なので no-op
if (!Element.prototype.scrollIntoView) {
  Element.prototype.scrollIntoView = function scrollIntoView() {};
}

// requestAnimationFrame: jsdom は提供するが、テストで同期実行したいケースがある。
// 個別テストで vi.useFakeTimers() と組み合わせて制御する。
if (typeof window.requestAnimationFrame !== 'function') {
  window.requestAnimationFrame = ((cb: FrameRequestCallback) =>
    setTimeout(() => cb(performance.now()), 16) as unknown as number);
  window.cancelAnimationFrame = ((id: number) => clearTimeout(id as unknown as NodeJS.Timeout));
}
