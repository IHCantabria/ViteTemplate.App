<script>
export default {
  name: "HelloWorld",
};
</script>

<script setup>
import { ref } from "vue";

defineProps({
  msg: {
    type: String,
    required: true,
  },
});

const count = ref(0);
</script>

<template>
  <h1>{{ msg }}</h1>

  <p>
    Recommended IDE setup:
    <a
      href="https://code.visualstudio.com/"
      target="_blank"
      rel="noopener noreferrer"
      >VSCode</a
    >
    +
    <a
      href="https://github.com/johnsoncodehk/volar"
      target="_blank"
      rel="noopener noreferrer"
      >Volar</a
    >
  </p>

  <p>
    <a
      href="https://vitejs.dev/guide/features.html"
      target="_blank"
      rel="noopener noreferrer"
    >
      Vite Documentation
    </a>
    |
    <a href="https://v3.vuejs.org/" target="_blank" rel="noopener noreferrer"
      >Vue 3 Documentation</a
    >
  </p>

  <button
    id="button-count"
    data-test="buttoncount"
    type="button"
    @click="count++"
  >
    Increment click count:{{ count }}
  </button>

  <div class="form-group">
    <label for="input-count"
      >Número de clics:
      <input
        id="input-count"
        v-model="count"
        data-test="inputcount"
        type="number"
        aria-describedby="input-count"
    /></label>
  </div>

  <p>
    Edit
    <code>components/HelloWorld.vue</code> to test hot module replacement.
  </p>
</template>

<style scoped>
a {
  color: #0a6825;
  text-decoration: underline;
}

a:hover {
  text-decoration: none;
  background-color: #f0f0f0;
}
</style>
