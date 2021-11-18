<template>
  <div />
</template>
<script>
import "@/libs/leaflet-wms-legend-master/leaflet.wmslegend";

export default {
  name: "LMapLegendExternal",
  props: {
    url: {
      type: String, //http or wms url
      required: true,
      default: () => {
        return "";
      }
    },
    active: {
      type: Boolean,
      required: false,
      default() {
        return false;
      }
    },
    layerName: {
      type: String,
      required: true,
      default: () => {
        return "";
      }
    },
    limits: {
      type: String, // "0,10"
      required: false,
      default: () => {
        return "0,50";
      }
    },
    numColorBands: {
      type: Number,
      required: false,
      default: () => {
        return 256;
      }
    },
    palette: {
      type: String,
      required: false,
      default: () => {
        return "rainbow";
      }
    },
    config: {
      type: Object,
      required: true,
      default: () => {
        return null;
      }
    }
  },
  data() {
    return {
      legend: {},
      map: this.$parent.mapObj,
      protocols: { HTTP: "HTTP", WMS: "WMS" }
    };
  },
  watch: {
    active() {
      if (this.active) {
        this.loadLegend();
      } else {
        this.removeLegend();
      }
    },
    url() {
      if (this.active) {
        // Clear legend before loading another legend
        this.removeLegend();
        this.loadLegend();
      }
    }
  },
  mounted() {
    this.init();
  },
  beforeDestroy() {
    this.removeLegend();
  },
  methods: {
    init() {
      if (this.active) this.loadLegend();
    },
    loadLegend() {
      switch (this.config.type) {
      case this.protocols.HTTP: {
        this.loadHTTPLegend();
        break;
      }
      case this.protocols.WMS: {
        this.loadWMSLegend();
        break;
      }
      }
    },
    loadWMSLegend() {
      const uri = this.getRequest();
      this.addLegend(uri);
    },
    getRequest() {
      return `${this.url}?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetLegendGraphic&FORMAT=${this.config.format}&LAYER=${this.layerName}&TRANSPARENT=${this.config.transparent}&COLORSCALERANGE=${this.limits}
      &NUMCOLORBANDS=${this.numColorBands}&PALETTE=${this.palette}`;
    },
    loadHTTPLegend() {
      this.addLegend(this.url);
    },
    addLegend(uri) {
      this.legend = new L.Control.WMSLegend({
        position: this.config.position ? this.config.position : "bottomright",
        uri: uri
      });
      this.legend.addTo(this.map);
    },
    removeLegend() {
      if (Object.keys(this.legend).length > 0) {
        this.map.removeControl(this.legend);
      }
    }
  }
};
</script>
<style lang="scss" src="./legend-external.scss"></style>
