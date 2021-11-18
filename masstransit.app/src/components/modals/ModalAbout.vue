<template>
  <div class="modal-about">
    <b-modal
      v-model="isModalOpen"
      has-modal-card
      trap-focus
      aria-role="dialog"
      aria-modal
    >
      <div class="modal-card">
        <header class="modal-card-head project-card__header">
          <div class="card-header-title project-card__title">
            <div>{{ title }}</div>
          </div>
          <button
            type="button"
            class="delete"
            @click="updateModalState(false)"
          />
        </header>
        <section class="modal-card-body">
          <the-about />
        </section>
      </div>
    </b-modal>
  </div>
</template>
<script>
import { defineComponent } from "@vue/runtime-core";
import TheAbout from "./layout/TheAbout"
const ModalAbout = defineComponent( {
  name: "ModalAbout",
  components: {
    TheAbout,
  },
  props: {
    active: {
      type: Boolean,
      required: true,
      default: () => {
        return false;
      },
    },
    title: {
      type: String,
      required: false,
      default: () => {
        return "";
      },
    },
  },
  computed: {
    isModalOpen: {
      get() {
        return this.active;
      },
      set(value) {
        this.updateModalState(value);
      },
    },
  },
  methods: {
    updateModalState(value) {
      this.$emit("update:active", value);
    },
  },
});
</script>
<style lang="scss" scoped>
.card-header-title {
  font-size: 110%;
}

.modal-card {
  width: 975px;
  z-index: 1000;
}

.project-card {
  &__header {
    padding: 0.5rem 1rem;
  }

  &__title {
    display: flex;
    flex-direction: row;
  }
}
</style>
