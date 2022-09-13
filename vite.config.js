import { fileURLToPath, URL } from "url";
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import viteCompression from "vite-plugin-compression";
import dns from "dns";
const zlib = require("zlib");
const fs = require("fs");

// Localhost instead of ip 127.0.0.1
dns.setDefaultResultOrder("verbatim");

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  //Workaround for building environments
  const dist = mode === "production" ? "dist/prod/" : "dist/dev/";
  return {
    plugins: [
      vue(),
      viteCompression({
        filter: new RegExp("\\.(js|json|css|html|svg)$", "i"),
        threshold: 10240,
        algorithm: "brotliCompress",
        ext: ".br",
        compressionOptions: {
          params: {
            [zlib.constants.BROTLI_PARAM_QUALITY]:
              zlib.constants.BROTLI_MAX_QUALITY,
            [zlib.constants.BROTLI_PARAM_MODE]: zlib.constants.BROTLI_MODE_TEXT,
          },
        },
        deleteOriginFile: false,
      }),
      viteCompression({
        filter: new RegExp("\\.(js|json|css|html)$", "i"),
        threshold: 10240,
        algorithm: "gzip",
        ext: ".gz",
        compressionOptions: {
          level: zlib.constants.Z_BEST_COMPRESSION,
        },
        deleteOriginFile: false,
      }),
    ],
    define: {
      __APP_VERSION__: JSON.stringify(require("./package.json").version),
    },
    resolve: {
      alias: {
        "@": fileURLToPath(new URL("./src", import.meta.url)),
        "~": fileURLToPath(new URL("src", import.meta.url)),
        //Example alias bulma sass
        bulma: "bulma/bulma.sass",
      },
    },
    server: {
      port: 8080,
      // Exits if port is already in use
      strictPort: true,
      // Https configuration, default is false
      https: {
        key: fs.readFileSync("./certificate/localhost-key.pem"),
        cert: fs.readFileSync("./certificate/localhost.pem"),
      },
    },
    preview: {
      port: 8080,
      strictPort: true,
      https: false,
    },
    build: {
      outDir: dist,
      reportCompressedSize: false,
    },
    css: {
      preprocessorOptions: {
        scss: {
          additionalData: "@use '@/styles/variables' as app-variables;",
        },
      },
      modules: {
        scopeBehaviour: "global",
      },
    },
    test: {
      include: ["__tests__/**/*.test.js"],
      environment: "jsdom",
      globals: true,
      deps: {
        inline: ["@vue"],
      },
    },
  };
});
