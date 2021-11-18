<template>
  <div />
</template>
<script>
import "ih-leaflet-canvaslayer-field/dist/leaflet.canvaslayer.field";
import chroma from "chroma-js";

export default {
  name: "LMapLegendColorBar",
  props: {
    active: {
      type: Boolean,
      required: false,
      default() {
        return true;
      }
    },
    config: {
      type: Object,
      required: false,
      default() {
        return {};
      }
    },
    palette: {
      type: [String, Array], // color string or array of colors
      required: false,
      default() {
        return "RdYlGn"; // Colors definitions from http://colorbrewer2.org.
      }
    },
    title: {
      type: String,
      required: true,
      default() {
        return "";
      }
    },
    range: {
      type: Array,
      required: false,
      default() {
        return [0, 100];
      }
    }
  },
  data() {
    return {
      colorScale: null,
      legend: null,
      map: this.$parent.mapObj
    };
  },
  watch: {
    title() {
      this.removeLegend(); // refresh legend on layer change
      if (this.title !== "" && this.active) {
        this.loadLegend();
      }
    }
  },
  mounted() {
    if (this.active) {
      this.loadLegend();
    }
  },
  destroyed() {
    this.removeLegend();
  },
  methods: {
    loadLegend() {
      this.colorScale = chroma.scale(this.palette).domain(this.range);
      this.legend = L.control.colorBar(this.colorScale, this.range, {        
        ...this.config,
        title: this.title + " (" + this._props.config.units + ")"
      });
      this.legend.addTo(this.map);
    },
    removeLegend() {
      if (Object.keys(this.legend).length > 0) {
        this.map.removeControl(this.legend);
        this.legend = null;
        this.colorScale = null;
      }
    }
  }
};
</script>
