<template>
  <div />
</template>
<script>
import "../../../libs/IHCantabria.Leaflet.Draw/leaflet.draw";

export default {
  name: "DrawControls",
  props: {
    drawOptions: {
      type: Object, //ie: { polygon: false, circle: false, rectangle: true, marker: false,...}
      required: false,
      default() {
        return null;
      },
    },
    editOptions: {
      type: Object, //ie: {edit: false, remove: true,...}
      required: false,
      default() {
        return null;
      },
    },
    customDrawStyle: {
      type: Object, //ie: { polygon: style, circle: style, rectangle: style, marker: style,...}
      required: false,
      default() {
        return {};
      },
    },
    customButtonsText: {
      type: Object,
      required: false,
      default() {
        return null;
      },
    },
  },
  data() {
    return {
      map: this.$parent.mapObj,
      drawnItems: {},
      drawLayer: {},
      buttonsText: {
        marker: "Set a marker on the map",
        rectangle: "Define a search area on the map",
      },
    };
  },
  mounted() {
    this.init();
  },
  methods: {
    init() {
      this.drawnItems = new L.FeatureGroup();
      this.map.addLayer(this.drawnItems);

      this.setupControl();
      this.setDrawEvents();
    },
    setupControl() {
      const drawControl = new L.Control.Draw({
        edit:
          this.editOptions !== null
            ? { featureGroup: this.drawnItems, ...this.editOptions }
            : { featureGroup: this.drawnItems },
        draw: this.drawOptions !== null ? this.drawOptions : {},
      });
      this.setButtonsTexts();
      this.map.addControl(drawControl);
    },
    setButtonsTexts() {
      L.drawLocal.draw.toolbar.buttons.rectangle =
        this.customButtonsText?.rectangle !== null
          ? this.customButtonsText.rectangle
          : this.buttonsText.rectangle;
      L.drawLocal.draw.toolbar.buttons.marker =
        this.customButtonsText?.marker !== null
          ? this.customButtonsText.marker
          : this.buttonsText.marker;
    },
    setDrawEvents() {
      const self = this;
      this.map.on("draw:created", (e) => {
        self.drawNewFeatures(e);
      });
      this.map.on("draw:edited", (e) => {
        self.editDrawnFeatures(e);
      });
    },
    drawNewFeatures(e) {
      this.clearDrawnLayer();
      this.drawFeatures(e.layer, e.layerType);
    },
    editDrawnFeatures(e) {
      this.clearDrawnLayer();
      const layers = e.layers;
      layers.eachLayer((layer) => {
        this.drawFeatures(layer, this.checkLayerType(layer));
      });
    },
    drawFeatures(layer, type) {
      this.drawLayer = this.customDrawStyle[type]
        ? this.setCustomStyle(layer, this.customDrawStyle[type])
        : layer;
      this.drawnItems.addLayer(this.drawLayer, true);
      this.onFeaturesDrawn(type);
    },
    onFeaturesDrawn(type) {
      if (type === "marker") {
        const geoJson = this.drawLayer.toGeoJSON();
        const lon = geoJson.geometry.coordinates[0].toFixed(6);
        const lat = geoJson.geometry.coordinates[1].toFixed(6);
        this.$emit("marker-drawn", { lon: lon, lat: lat });
      }
      if (type === "rectangle") {
        const extent = L.LatLngUtil.cloneLatLngs(this.drawLayer._latlngs)[0];
        this.$emit("rectangle-drawn", extent);
      }
    },
    setCustomStyle(layer, style) {
      return layer.setStyle(style);
    },
    checkLayerType(layer) {
      let type = null;
      if (layer instanceof L.Rectangle) {
        type = "rectangle";
      } else if (layer instanceof L.Polygon) {
        type = "polygon";
      } else if (layer instanceof L.Polyline) {
        type = "polyline";
      } else if (layer instanceof L.Marker) {
        type = "marker";
      } else if (layer instanceof L.Circle) {
        type = "circle";
      }
      return type;
    },
    clearDrawnLayer() {
      this.drawnItems.clearLayers();
    },
  },
};
</script>
<style src="../../../libs/IHCantabria.Leaflet.Draw/leaflet.draw.css" />
