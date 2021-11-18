<template>
  <div class="questionnaire-grid">
    <the-map></the-map>
  </div>
</template>

<script>
import TheMap from "../components/layout/TheMap.vue";

export default {
  components: {
    TheMap,
  },
};
</script>

<style lang="scss" scoped>
.questionnaire-grid {
  position: relative;
  display: grid;
  grid-template-rows: calc(100vh - #{$height-header});
  grid-template-columns: 1fr;
  overflow-x: hidden;
}
</style>
