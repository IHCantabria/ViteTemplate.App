import { createApp } from "vue";
import App from "./App.vue";
import "../node_modules/bulma/css/bulma.css";
import router from "./router";

const app = createApp(App).use(router);

router
  .isReady()
  .then(() => {
    app.mount("#app");
    return;
  })
  .catch((err) => {
    // eslint-disable-next-line no-console
    console.error(err);
  });
