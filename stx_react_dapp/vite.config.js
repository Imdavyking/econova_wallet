import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

import { NodeGlobalsPolyfillPlugin } from "@esbuild-plugins/node-globals-polyfill";
import { NodeModulesPolyfillPlugin } from "@esbuild-plugins/node-modules-polyfill";
import rollupNodePolyFill from "rollup-plugin-polyfill-node";
import { nodePolyfills } from "vite-plugin-node-polyfills";
import wasm from "vite-plugin-wasm";
// https://vite.dev/config/

const forceHeaders = () => ({
  name: "force-cross-origin-headers",
  configureServer(server) {
    server.middlewares.use((req, res, next) => {
      res.setHeader("Cross-Origin-Embedder-Policy", "require-corp");
      res.setHeader("Cross-Origin-Resource-Policy", "cross-origin");
      next();
    });
  },
});

export default defineConfig({
  plugins: [
    forceHeaders(),
    tailwindcss(),
    react(),
    wasm(),
    nodePolyfills({
      include: ["process", "util", "path", "buffer"],
    }),
  ],
  define: {
    "process.env": {},
    global: "globalThis",
  },
  resolve: {
    alias: {
      // Fix for pino browser compatibility
      pino: "pino/browser.js",
    },
  },
  server: {
    headers: {
      "Cross-Origin-Opener-Policy": "same-origin",
      "Cross-Origin-Embedder-Policy": "require-corp",
    },
  },
  optimizeDeps: {
    exclude: ["@aztec/bb.js", "@noir-lang/noir_js", "@noir-lang/acvm_js"],
    include: ["pino"],
    esbuildOptions: {
      target: "esnext",
      define: {
        global: "globalThis",
      },
      plugins: [
        NodeGlobalsPolyfillPlugin({
          buffer: true,
          process: false,
        }),
        NodeModulesPolyfillPlugin(),
      ],
    },
  },

  build: {
    target: "esnext",
    rollupOptions: {
      plugins: [rollupNodePolyFill()],
    },
  },
});
