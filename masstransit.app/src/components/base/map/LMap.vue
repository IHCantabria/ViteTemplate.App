<template>
  <div id="simpleMap" ref="mapElement" class="map">
    <slot v-if="ready" name="controls" />
    <slot v-if="ready" name="layers" />
  </div>
</template>
<script>
import L from "leaflet";

import providers from "../../../config/basemaps-providers";

export default {
  name: "LMap",
  props: {
    baseLayer: {
      type: Object,
      required: false,
      default() {
        return {
          name: "esri-gray",
          alias: "Gray - ESRI",
        };
      },
    },
    center: {
      type: Object,
      required: false,
      default() {
        return { lon: -2.9, lat: 43.853, zoom: 3 };
      },
    },
    mapOptions: {
      type: Object, // ie: {zoomControl: false, attributionControl: true}
      required: false,
      default() {
        return {};
      },
    },
  },
  data() {
    return {
      baseMapLayer: {},
      initialView: this.center,
      mapObj: {},
      layerSwitcher: {},
      options: this.mapOptions,
    };
  },
  computed: {
    ready() {
      return Object.keys(this.mapObj).length > 0;
    },
  },
  watch: {
    center: {
      handler(newView) {
        this.centerMap(newView);
      },
    },
  },
  mounted() {
    this.$nextTick(() => {
      this.initMap();
      this.$emit("ready", this.mapObj);
    });
  },
  beforeDestroy() {
    if (this.mapObj) {
      this.mapObj.remove();
    }
  },
  methods: {
    initMap() {
      this.mapObj = L.map(this.$refs["mapElement"], this.mapOptions);
      this.createResizeObserver();
      this.addBaseLayer();
      this.centerMap(this.initialView);
    },
    centerMap(view) {
      this.mapObj.setView([view.lat, view.lon], view.zoom);
    },
    addBaseLayer() {
      const provider = this.getProvider(this.baseLayer.name);
      this.baseMapLayer = L.tileLayer(provider.url, provider.props).addTo(
        this.mapObj
      );
    },
    getProvider: (name) => {
      const provider = providers.find((provider) => {
        return provider.name === name;
      });
      return provider || providers[0];
    },
    createResizeObserver() {
      const self = this;
      const resizeObserver = new ResizeObserver(() => {
        self.invCall();
      });
      resizeObserver.observe(this.$refs["mapElement"]);
    },
    invCall() {
      this.mapObj.invalidateSize();
    },
  },
};
</script>
<style src="leaflet/dist/leaflet.css"></style>
<style lang="scss" scoped>
.map {
  width: 100%;
  height: 100%;
}
</style>
