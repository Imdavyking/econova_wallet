import { defineConfig } from "vite";
import wasm from "vite-plugin-wasm";
import { NodeGlobalsPolyfillPlugin } from "@esbuild-plugins/node-globals-polyfill";
import { NodeModulesPolyfillPlugin } from "@esbuild-plugins/node-modules-polyfill";
import rollupNodePolyFill from "rollup-plugin-polyfill-node";
import { nodePolyfills } from "vite-plugin-node-polyfills";
import react from "@vitejs/plugin-react";
import { viteStaticCopy } from "vite-plugin-static-copy";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = fileURLToPath(new URL(".", import.meta.url));

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

export default defineConfig(({ mode }) => {
  const isZkWorker = mode === "zkworker";

  return {
    plugins: [
      forceHeaders(),
      wasm(),
      nodePolyfills({
        include: ["process", "util", "path", "buffer"],
      }),
      // Copy WASM files next to the output JS when building zkworker
      ...(isZkWorker
        ? [
            viteStaticCopy({
              targets: [
                {
                  src: path.resolve(
                    __dirname,
                    "node_modules/@noir-lang/acvm_js/web/acvm_js_bg.wasm",
                  ),
                  dest: ".",
                },
                {
                  src: path.resolve(
                    __dirname,
                    "node_modules/@noir-lang/noirc_abi/web/noirc_abi_wasm_bg.wasm",
                  ),
                  dest: ".",
                },
              ],
            }),
          ]
        : []),
    ],
    define: {
      "process.env": {},
      global: "globalThis",
    },
    resolve: {
      alias: {
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
      ...(isZkWorker
        ? {
            outDir: "dist-zkworker",
            lib: {
              entry: "src/zkworker.ts",
              name: "zkworker",
              formats: ["es"],
              fileName: () => "zkworker.js",
            },
          }
        : {
            outDir: "dist",
          }),
      rollupOptions: {
        plugins: [rollupNodePolyFill()],
      },
    },
  };
});
