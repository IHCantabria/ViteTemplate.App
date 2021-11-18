import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import globalStyle from "@originjs/vite-plugin-global-style";

const fs = require("fs");

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue(), globalStyle({ sourcePath: "src/styles" })],
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
  // css: {
  //   preprocessorOptions: {
  //     scss: {
  //       additionalData: '@import "src/styles/main.scss" ;',
  //     },
  //   },
  // },
});
