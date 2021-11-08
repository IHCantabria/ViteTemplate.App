const StyleLintPlugin = require("stylelint-webpack-plugin");
const fs = require("fs");
module.exports = {
  chainWebpack: (config) => {
    //distintos comportamientos de devtool según entorno
    if (process.env.NODE_ENV === "production") {
      //Build PRO
      config.devtool("none");
    } else if (!process.env.WEBPACK_DEV_SERVER) {
      //BUILD DEV
      config.devtool("eval-source-map");
    } else {
      //LOCAL DEV
      config.devtool("source-map");
    }
    //publicar variable de versión para usarla en el proyecto
    config.plugin("define").tap((definitions) => {
      definitions[0]["process.env"]["VERSION"] = JSON.stringify(
        require("./package.json").version
      );
      return definitions;
    });
  },
  outputDir: process.env.VUE_APP_DEPLOY_DIR,
  runtimeCompiler: true,
  devServer: {
    open: true,
    //localhost en https y carga de certificado
    https: true,
    key: fs.readFileSync("./certificate/localhost-key.pem"),
    cert: fs.readFileSync("./certificate/localhost.pem"),
  },
  configureWebpack: {
    plugins: [
      //configuración de stylelint en build
      new StyleLintPlugin({
        fix: true,
        files: "src/**/*.{vue,htm,html,css,sass,less,scss}",
        formatter: () => {},
      }),
    ],
  },
  pluginOptions: {
    webpackBundleAnalyzer: {
      openAnalyzer: false,
    },
  },
  css: {
    loaderOptions: {
      scss: {
        // to import styles global variables
        additionalData: `
          @import "~@/styles/main.scss";
        `,
        sassOptions: {
          quietDeps: true,
        },
      },
    },
  },
};
