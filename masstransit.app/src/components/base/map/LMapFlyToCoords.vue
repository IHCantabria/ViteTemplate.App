<template>
  <div />
</template>
<script>
export default {
  name: "LMapFlyToCoords",
  props: {
    geoJson: {
      type: Object, // {GeoJSON Object}
      required: true,
      default: () => {
        return {};
      }
    },
    maxZoom: {
      type: Number, // Max Zoom Fly
      required: false,
      default: () => {
        return null;
      }
    }
  },
  data() {
    return {
      map: this.$parent.mapObj,
      maxZoomFly: 0
    };
  },
  computed: {
    readyGeoJSON() {
      return Object.keys(this.geoJson).length > 0;
    }
  },
  watch: {
    geoJson: {
      handler() {
        this.checkGeoJSON();
      },
      deep: true
    },
    maxZoom: {
      handler() {
        this.changeMaxZoom();
      }
    }
  },
  mounted() {
    this.$nextTick(() => {
      this.init();
    });
  },
  methods: {
    init() {
      this.setMaxZoom();
    },
    setMaxZoom() {
      this.maxZoomFly = this.maxZoom ? this.maxZoom : this.map.options.maxZoom;
    },
    changeMaxZoom() {
      this.maxZoomFly = this.maxZoom;
    },
    checkGeoJSON() {
      if (this.readyGeoJSON) this.getGeoJSONBounds();
    },
    getGeoJSONBounds() {
      const features = L.geoJSON(this.geoJson);
      const bounds = features.getBounds();
      this.flyGoTo(bounds);
    },
    flyGoTo(coords) {
      this.map.flyToBounds(coords, { maxZoom: this.maxZoomFly });
    }
  }
};
</script>
