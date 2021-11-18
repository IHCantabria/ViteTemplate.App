<template>
  <base-navbar :brandLogo="navbarLogoPath" :title="navbarTitle" :items="navbarItems" />
</template>
<script>
import BaseNavbar from "../base/BaseNavbar.vue";
export default {
  components: { BaseNavbar },
  data() {
    return {
      navbarItems: [
        {
          name: "questionnaire",
          alias: "Questionnaire",
          path: "/questionnaire",
        },
      ],
      navbarLogoPath: "src/assets/logos/Logo_IFC_Blanco_2.png",
      navbarTitle: "Mass Transit"
    };
  },
  methods: {
    launchAbout() {
      this.$emit("launch-about");
    },
  },
};
</script>
<style lang="scss" scoped>
.navbar {
  padding: 2rem 1rem;
}
.brand-title {
  color: $app-font-secondary-color;
  margin-left: 3rem;
  letter-spacing: 0.15em;
  font-weight: 500;
}

.brand-subtitle {
  color: $primary-color-dark;
}

.navbar-title {
  margin-right: 1rem;
  // border-right: 1px solid white;
  padding-right: 2rem;

  &__item {
    color: $app-font-secondary-color;
  }

  &__active {
    text-decoration: underline;
  }
}

.navbar-buttons {
  border-left: 2px solid $app-font-secondary-color;
  display: inline-flex;
  padding-left: 0.2rem;

  & a {
    padding: 0.5rem 0.75rem;
  }

  & a:hover {
    background-color: $primary-color-light;
  }
}

.nav-icons {
  color: $app-font-secondary-color;
}

.navbar-item {
  color: white;

  & img {
    max-height: 2.5rem;
  }
}

a.navbar-item:focus {
  background-color: transparent;
  color: $app-font-secondary-color;
}

a.navbar-item:focus-within {
  background-color: transparent;
  color: $app-font-secondary-color;
}

a.navbar-item:hover {
  background-color: $primary-color-light;
  color: white;
}

.navbar {
  background-color: $primary-color;
}

.router-link-active {
  text-decoration: underline;
}

.label-version {
  text-align: center;
  font-size: 0.8rem;
  display: flex;
  flex-direction: column;
  padding: 0.5rem 1rem 0.5rem 1rem;
}

.about-container {
  &__title-logo {
    display: flex;
    padding: 0.5rem 1rem 0.5rem 1rem;

    & img {
      margin-left: auto;
      margin-right: auto;
      max-height: 9vh;
    }
  }

  &__msg-section {
    font-size: 0.7rem;
    text-align: left;
    padding: 0.5rem 1rem;
  }

  &__logos {
    display: flex;
    flex-flow: wrap row;
    justify-content: center;
    height: 100%;
    width: 100%;
    padding-top: 1rem;

    .logo {
      padding: 0.5rem 0;

      & img {
        max-height: 8.2vh;
        height: 100%;
      }
    }
  }
}
</style>
