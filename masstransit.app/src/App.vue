<script setup>
// This starter template is using Vue 3 <script setup> SFCs
// Check out https://v3.vuejs.org/api/sfc-script-setup.html#sfc-script-setup
import HelloWorld from "./components/HelloWorld.vue";
import TheNavBar from "./components/layout/TheNavBar.vue";
</script>

<template>
  <div class="grid">
    <header>
      <TheNavBar />
    </header>
    <main>
      <HelloWorld msg="Hello Vue 3 + Vite" />
    </main>
  </div>
</template>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #569b1d;
  /* margin-top: 60px; */
}

.grid {
  display: grid;
  position: relative;
  grid-template-rows: 20vh 1fr;
  grid-template-columns: 1fr;
  grid-row-gap: 0;
  height: 100vh;
  overflow-x: hidden;
}
</style>
