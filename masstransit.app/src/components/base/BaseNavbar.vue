<template>
  <nav class="navbar" role="navigation" aria-label="main navigation">
    <div class="navbar-brand">
      <a class="navbar-item" href="">
        <img :src="brandLogo" class="navbar-brand__logo" />
      </a>

      <div class="navbar-title">
        <p class="title is-3 is-spaced brand-title">
          {{ title }}
        </p>
      </div>
      <a
        role="button"
        class="navbar-burger"
        aria-label="menu"
        aria-expanded="false"
        data-target="navbarBasicExample"
      >
        <span aria-hidden="true" />
        <span aria-hidden="true" />
        <span aria-hidden="true" />
      </a>
    </div>

    <div id="navbarBasicExample" class="navbar-menu">
      <div class="navbar-start">
        <a v-for="(item, index) in items" :key="index" class="navbar-item">
          {{ item.alias }}
        </a>

        <!-- <a class="navbar-item">
        Documentation
      </a>

      <div class="navbar-item has-dropdown is-hoverable">
        <a class="navbar-link">
          More
        </a>

        <div class="navbar-dropdown">
          <a class="navbar-item">
            About
          </a>
          <a class="navbar-item">
            Jobs
          </a>
          <a class="navbar-item">
            Contact
          </a>
          <hr class="navbar-divider">
          <a class="navbar-item">
            Report an issue
          </a>
        </div>
      </div> -->
      </div>

      <div class="navbar-end">
        <div class="navbar-item">
          <div class="buttons">
            <a v-if="hasLogin" class="button is-light"> Log in </a>
            <a v-if="hasInfo" class="button is-light"> About </a>
          </div>
        </div>
      </div>
    </div>
  </nav>
</template>
<script>
export default {
  props: {
    brandLogo: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    items: {
      type: Array, //[{ name: String, alias: String, path: String }, ...]
      required: false,
      default() {
        return [];
      },
    },
    hasLogin: {
      type: Boolean,
      required: false,
      default() {
        return false;
      },
    },
    hasInfo: {
      type: Boolean,
      required: false,
      default() {
        return false;
      },
    },
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
  font-family: $app-font;
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
