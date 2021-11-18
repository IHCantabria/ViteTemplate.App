<template>
  <div />
</template>
<script>
import providers from "@/config/basemaps-providers";

export default {
  name: "LMapLayerControl",
  props: {
    baseLayers: {
      type: Array,
      required: false,
      default() {
        return [
          {
            name: "esri-gray",
            alias: "Gray - ESRI"
          }
        ];
      }
    },
    overlayLayers: {
      type: Array,
      required: false,
      default() {
        return [];
      }
    }
  },
  data() {
    return {
      map: this.$parent.mapObj
    };
  },
  mounted() {
    this.$nextTick(() => {
      this.init();
    });
  },
  beforeDestroy() {
    this.removeControl();
  },
  methods: {
    init() {
      this.addLayerSwitcher();
    },
    addLayerSwitcher() {
      const baseMaps = this.createBaseMapLayers();
      const overlayMaps = this.createOverlayMapLayers();
      this.$parent.layerSwitcher = L.control
        .layers(baseMaps, overlayMaps)
        .addTo(this.map);
      this.map.removeLayer(this.$parent.baseMapLayer); //remove BaseMapLayer from LMap
      baseMaps[Object.keys(baseMaps)[0]].addTo(this.map); //init first by default
      this.$parent.layerSwitcher.addTo(this.map);
    },
    createBaseMapLayers() {
      const baseMaps = {};
      this.baseLayers.forEach((baseLayer) => {
        const provider = this.getProvider(baseLayer.name);
        baseMaps[baseLayer.alias] = L.tileLayer(provider.url, provider.props);
      });
      return baseMaps;
    },
    createOverlayMapLayers() {
      const overlayMaps = {};
      this.overlayLayers.forEach((overlayLayer) => {
        const provider = this.getProvider(overlayLayer.name);
        overlayMaps[overlayLayer.alias] = L.tileLayer(
          provider.url,
          provider.props
        );
      });
      return overlayMaps;
    },
    getProvider: (name) => {
      const provider = providers.find((provider) => {
        return provider.name === name;
      });
      return provider || providers[0];
    },
    removeControl() {
      this.map.removeControl(this.$parent.layerSwitcher); // remove layerSwitcher from parent LMap
    }
  }
};
</script>
