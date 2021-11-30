import { defineConfig } from "vite";
import { resolve } from "path";
import vue from "@vitejs/plugin-vue";
import globalStyle from "@originjs/vite-plugin-global-style";

const fs = require("fs");

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  //Workaround for building environments
  var dist;
  if (mode === "production") {
    dist = "dist/prod/";
  } else {
    dist = "dist/dev/";
  }

  return {
    plugins: [vue(), globalStyle({ sourcePath: "src/styles" })],
    resolve: {
      alias: {
        "@": resolve(__dirname, "./src"),
        "~": resolve(__dirname, "src"),
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
    },
  };
});
