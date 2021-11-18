<template>
  <div id="layerGeoserverWMS">
    <slot
      v-if="ready"
      name="legend"
    />
    <slot
      v-if="ready"
      name="identify"
    />
  </div>
</template>
<script>
export default {
  props: {
    layer: {
      type: Object,
      required: true
    },
    showInLayerSwitcher: {
      type: Boolean,
      required: false,
      default: false
    },
    showOnLoad: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  data() {
    return {
      map: this.$parent.mapObj,
      wmsLayer: null
    };
  },
  computed: {
    ready() {
      return this.layer !== null;
    }
  },
  watch:{
    layer(){
      // Clear map before loading another layer
      this.removeLayer();
      this.loadWmsLayer();
    }
  },
  destroyed() {
    this.removeLayer();
  },
  mounted() {
    if (this.ready) {
      this.loadWmsLayer();
    }
  },
  methods: {
    loadWmsLayer() {
      this.wmsLayer = L.tileLayer.wms(this.layer.url, this.layer.wmsOptions);
      this.setLayerEvents();

      if (this.showInLayerSwitcher) {
        this.$nextTick(() => {
          this.$parent.layerSwitcher.addOverlay(
            this.wmsLayer,
            this.layer.wmsOptions.alias,
            this.layer.group
          );
        });
      }
      if (this.showOnLoad) {
        this.$nextTick(() => {
          this.wmsLayer.addTo(this.map);
        });
      }
    },
    setLayerEvents() {
      const self = this;
      this.wmsLayer.on("add", () => {
        self.$emit("on-visibility-change", true);
      });
      this.wmsLayer.on("remove", () => {
        self.$emit("on-visibility-change", false);
      });
    },
    removeLayer() {
      if (Object.keys(this.wmsLayer).length > 0) {
        this.map.removeLayer(this.wmsLayer);
      }
    }
  }
};
</script>
