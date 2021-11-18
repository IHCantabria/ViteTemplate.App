<template>
  <l-map :center="center">
    <template v-slot:controls>
      <l-map-draw-controls
        ref="drawMarkerControl"
        :drawOptions="drawControl.drawOptions"
        :editOptions="drawControl.editOptions"
        :customButtonsText="drawControl.buttonsText"
        @marker-drawn="onMarkerDrawn"
      />
    </template>
  </l-map>
</template>
<script>
import LMap from "../base/map/LMap.vue";
import LMapDrawControls from "../base/map/LMapDrawControls.vue";
export default {
  components: {
    LMap,
    LMapDrawControls,
  },
  data() {
    return {
      center: { lon: -2.9, lat: 43.853, zoom: 3 },
      drawControl: {
        visible: true,
        drawOptions: {
          polyline: false,
          polygon: false,
          circle: false,
          circlemarker: false,
          marker: true,
          rectangle: false,
        },
        editOptions: { edit: false, remove: false },
        buttonsText: { marker: "Select a location on the map" },
      },
    };
  },
  methods: {
    onMarkerDrawn(position) {
      // TODO: implement coords logic
      console.log({
        lat: parseFloat(position.lat).toFixed(4),
        lon: parseFloat(position.lon).toFixed(4),
      });
    },
  },
};
</script>
