/// <reference types="vitest" />
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { viteSingleFile } from 'vite-plugin-singlefile';

// Single-file HTML build:
// - viteSingleFile() inlines JS/CSS into dist/index.html
// - assetsInlineLimit: Infinity ensures any future asset (images, fonts) is also inlined,
//   preserving the guarantee that the output works over file:// with no external fetches.
export default defineConfig({
  plugins: [react(), viteSingleFile()],
  build: {
    outDir: 'dist',
    assetsInlineLimit: Infinity,
  },
  test: {
    environment: 'jsdom',
    setupFiles: './src/setupTests.ts',
    globals: true,
  },
});
