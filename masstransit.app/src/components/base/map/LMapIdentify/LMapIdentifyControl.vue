<template>
  <div />
</template>
<script>
import "proj4leaflet";

export default {
  name: "LMapIdentifyControl",
  props: {
    urlBase: {
      type: String,
      required: false, // only needed for REST
      default: "",
    },
    type: {
      type: String,
      required: false,
      default: "REST",
    },     
    active: {
      type: Boolean,
      required: true,
    },
    triggerLocation: { //force a map click on specific coords
      type: Object, // ie: { lon:2.23, lat:39.34 }
      required: false,
      default () {
        return null;
      }
    },
    projection: {
      type: Object,
      required: false,
      default: () => {
        return {
          code: "EPSG:3857",
          proj4def:
            "+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +a=6378137 +b=6378137 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs",
        };
      },
    },
  },
  data() {
    return {
      map: this.$parent.map,
    };
  },
  computed: {
    hasSecondaryLayer() {
      if (!this.$parent.wmsSecondaryLayer) return false;
      if (Object.keys(this.$parent.wmsSecondaryLayer).length === 0)
        return false;
      return true;
    },
  },
  watch: {
    active() {
      if (this.active) {
        this.init();
      } else {
        this.removeControl();
      }
    },
    triggerLocation(coords){         
      if (coords){
        this.map.fireEvent('click', {
          latlng: L.latLng(coords.lat, coords.lon)
        });
      }
    }
  },
  created() {
    this.PROTOCOLS = {
      REST: "REST",
      WMS: "WMS",
      WCS: "WCS",
      WCS_VECTOR: "WCS_VECTOR",
    };
  },
  destroyed() {
    this.removeControl();
  },
  mounted() {
    if (this.active) {
      this.init();
    }
  },
  methods: {
    init() {      
      switch (this.type) {
      case this.PROTOCOLS.REST: {
        this.map.on("click", this.setupRESTService());
        break;
      }
      case this.PROTOCOLS.WMS: {
        this.map.on("click", this.hasSecondaryLayer ? this.setupDoubleWMSService(): this.setupSingleWMSService());
        break;
      }
      case this.PROTOCOLS.WCS: {
        this.$parent.wcsRasterLayer.options.onClick = this.setupWCSService(
          false
        );
        break;
      }
      case this.PROTOCOLS.WCS_VECTOR: {
        this.$parent.wcsVectorLayer.options.onClick = this.setupWCSService(
          true
        );
        break;
      }
      }      
    },
    setupRESTService() {
      const self = this;
      return (e) => {
        if (self.active) {
          var url = `${this.urlBase}?geom=POINT(${e.latlng.lng} ${e.latlng.lat})`;
          fetch(url)
            .then((response) => {
              if (!response.ok) {
                throw Error(response.statusText);
              }
              return response.text();
            })
            .then((jsonData) => {
              const data = JSON.parse(jsonData);
              self.$emit('rest-layer-click', {coords: e.latlng, jsonData:data})
              const content = self.createContentFromJson(data);
              self.openPopup(e.latlng, content);
              return true;
            })
            .catch(() => {
              // eslint-disable-next-line no-console
              console.log("No data in this point");
            });
        }
      };
    },
    setupSingleWMSService(){
      const self = this;
      return function(e) {        
        var url = self.getFeatureInfoUrl(
          self.map,
          e.latlng,
          {},
          self.$parent.wmsLayer
        );          
        self.getWMSPointInfo(e, url);
      };
    },
    setupDoubleWMSService() {
      const self = this;
      return function(e) {
        if (
          self.active &&
          e.originalEvent.target.className !== "leaflet-sbs-range" //Workaround to fix sidebyside control propragating click event
        ) {
          var url = self.getFeatureInfoUrl(
            self.map,
            e.latlng,
            {},
            self.$parent.wmsLayer
          );
          // popup with two layers values
          if (this.hasSecondaryLayer) {
            var urlSecondary = self.getFeatureInfoUrl(
              self.map,
              e.latlng,
              {},
              self.$parent.wmsSecondaryLayer
            );            
            self.getWMSDoublePointInfo(e, url, urlSecondary);
          } else {            
            self.getWMSPointInfo(e, url);            
          }
        }        
      };
    },
    getFeatureInfoUrl(map, latlng, params, layer) {
      // Build the URL for a GetFeatureInfo
      var crs = new L.Proj.CRS(this.projection.code, this.projection.proj4def);
      var point = map.latLngToContainerPoint(latlng, map.getZoom());
      var size = map.getSize();
      var bounds = map.getBounds();
      var sw = bounds.getSouthWest();
      var ne = bounds.getNorthEast();
      sw = crs.projection._proj.forward([sw.lng, sw.lat]);
      ne = crs.projection._proj.forward([ne.lng, ne.lat]);

      const defaultParams = {
        request: "GetFeatureInfo",
        service: "WMS",
        srs: layer._crs.code,
        styles: "",
        version: "1.1.1",
        format: layer.options.format,
        bbox: [sw.join(","), ne.join(",")].join(","),
        height: size.y,
        width: size.x,
        layers: layer.options.layers,
        query_layers: layer.options.layers,
        info_format: "text/xml",
      };

      params = L.Util.extend(defaultParams, params || {});
      params[params.version === "1.3.0" ? "i" : "x"] = parseInt(point.x);
      params[params.version === "1.3.0" ? "j" : "y"] = parseInt(point.y);

      return layer._url + L.Util.getParamString(params, layer._url, true);
    },
    setupWCSService() {
      const self = this;
      return function(e) {
        if (e.value !== null) {
          self.$emit('wcs-layer-click', e)          
        }
      };
    },
    getWMSPointInfo(e, url){
      const self = this;
      fetch(url)
        .then((response) => {
          return response.text();
        })
        .then(function(xml) {
          self.$emit('wms-layer-click', { event: e, data:[xml] });         
          return true;                
        })
        .catch(() => {
          // eslint-disable-next-line no-console
          console.log("No data in this point");
        });
    },
    getWMSDoublePointInfo(e, url, urlSecondary){
      //TODO: change async request concatenation
      const self = this;
      fetch(url)
        .then((response) => {
          return response.text();
        })

        // eslint-disable-next-line promise/always-return
        .then(function(xml) {
          const parser = new DOMParser();
          const xmlDoc = parser.parseFromString(xml, "text/xml");

          // eslint-disable-next-line promise/no-nesting
          fetch(urlSecondary)
            .then((response) => {
              return response.text();
            })
            .then(function(xmlSecondary) {
              const parser = new DOMParser();
              const xmlDocSecondary = parser.parseFromString(
                xmlSecondary,
                "text/xml"
              );
              self.$emit('wms-double-layer-click', { event: e, data:[xmlDoc, xmlDocSecondary] });             
              return true;
            })
            .catch(() => {
              // eslint-disable-next-line no-console
              console.log("No data in this point");
            });
        })
        .catch(() => {
          // eslint-disable-next-line no-console
          console.log("No data in this point");
        });
    },
    removeControl() {
      this.map.off("click"); // remove event listener for identify
    },
  },
};
</script>
<style lang="scss" src="./identify-control.scss"></style>
