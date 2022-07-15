<script>
export default {
  name: "App",
};
</script>
<script setup>
// This starter template is using Vue 3 <script setup> SFCs
// Check out https://v3.vuejs.org/api/sfc-script-setup.html#sfc-script-setup
import HelloWorld from "./components/HelloWorld.vue";
</script>

<template>
  <div class="grid">
    <div class="main">
      <img alt="Vue logo" src="./assets/logo.png" />
      <HelloWorld msg="Vue 3 + Vite Template" />
    </div>
  </div>
</template>

<style lang="scss">
@use "@/styles";
</style>

<style lang="scss" scoped>
.app {
  text-align: center;
}

.grid {
  display: grid;
  position: relative;
  grid-template-rows: app-variables.$height-header 1fr;
  grid-template-columns: 1fr;
  grid-row-gap: 0;
  height: 100vh;
  overflow-x: hidden;
}

.main {
  width: 100%;
  height: 100vh;
}
</style>
