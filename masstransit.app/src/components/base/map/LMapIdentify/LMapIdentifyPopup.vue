<template>
  <div />    
</template>
<script>
export default {
  name: "LMapIdentifyPopup",
  props:{    
    identifyObj:{
      type: Object,
      required: false, 
      default(){
        return { event: null, data: null } //data could be json or xml
      }        
    },   
    layerType:{
      type: String,
      required: false, 
      default: 'REST' // 'REST' | 'WMS' | 'WCS' | 'WCS_VECTOR'
    },
    fields: {
      type: Array, // [{name:'', alias:''}.{...}]
      required: false,
      default() {
        return [
          {
            name: "value",
            alias: "-",
            units: "%",
            toUnits: true,
          },
        ];
      }
    },
  },
  data(){
    return{
      map: this.$parent.map,
      popup:null
    }
  },
  watch: {
    identifyObj(value) {
      value ? this.showPopup() : this.hidePopup();
    },
  },
  created(){
    this.PROTOCOLS = {
      REST: "REST",
      WMS: "WMS",
      WCS: "WCS",
      WCS_VECTOR: "WCS_VECTOR",
    };   
  },
  destroyed(){    
    this.hidePopup();
  },
  methods:{    
    showPopup(){      
      const popupHtml = this.createPopupContent();
      this.popup = L.popup()
        .setLatLng(this.identifyObj.event.latlng)
        .setContent(popupHtml);
      this.popup.openOn(this.map);       
    },
    hidePopup(){
      this.map.closePopup(this.popup);  
    },
    createPopupContent(){        
      if (this.layerType === this.PROTOCOLS.WCS_VECTOR)
        return this.getPopupHtmlFromWcsVectorLayer(this.identifyObj.event);        
      if (this.layerType === this.PROTOCOLS.WCS)
        return this.getPopupHtmlFromWcsRasterLayer(this.identifyObj.event);
      if (this.layerType === this.PROTOCOLS.WMS)
        return this.getPopupHtmlFromWMSLayer(this.identifyObj.event, this.identifyObj.data);     
      if (this.layerType === this.TYPE_REST_SERVICE)
        return this.restLayerPopup(this.identifyObj.event, this.identifyData.data);
    },    
    getPopupHtmlFromWcsVectorLayer(e) {
      const v = e.value;
      const m = v.magnitude().toFixed(2);
      const d = v.directionTo().toFixed(2);
      const layer = e.target;
      var t = new Date(layer.time).toUTCString();
      return `<div><strong>${this.fields[0].alias} </strong><br/>
                 <span>${m} ${
        !this.fields[0].units ? "" : this.fields[0].units
      } from ${d}&#176;</span><br/>
                 <span>at ${t}</span>
                </div>`;      
    },
    getPopupHtmlFromWcsRasterLayer(e) {
      const v = e.value.toFixed(2);
      const layer = e.target;
      const t = new Date(layer.time).toUTCString();
      return `<div><strong>${this.fields[0].alias}</strong><br/>
                        <span>${v} ${
        !this.fields[0].units ? "" : this.fields[0].units
      }</span><br/>
                        <span>at ${t}</span>
                  </div>`;      
    },
    getPopupHtmlFromWMSLayer(e, xmlData){
      const parser = new DOMParser();
      const xmlDoc = parser.parseFromString(xmlData[0], "text/xml");
     
      if (xmlData.length > 1) {        
        const xmlDocSecondary = parser.parseFromString(
          xmlData[1],
          "text/xml"
        );
        return this.createTwoLayersContentFromXml(
          xmlDoc,
          xmlDocSecondary
        );                 
      }      
      return this.createContentFromXml(xmlDoc);        
    },    
    createContentFromJson(data) {
      let content = "<div class='variable-container'>";
      for (const field of this.fields) {
        // eslint-disable-next-line no-prototype-builtins
        if (data.hasOwnProperty(field.name)) {
          const value = data[field.name];
          if (!isNaN(value)) {
            const fieldHtml = `<div class="variable-container__title">${
              field.alias
            }</div><div class="variable-container__value">${value}${
              value === "No Data" || !field.units ? "" : field.units
            }</div>`;
            content = content + fieldHtml;
          }
        }
      }
      content = content + "</div>";
      return content;
    },
    createContentFromXml(xmlDoc) {
      let content = "<div class='variable-container'>";
      for (const field of this.fields) {
        const contentValue = xmlDoc.getElementsByTagName(field.name)[0]
          .textContent;
        const value = this._getValue(field, contentValue);
        const fieldHtml = `<div class="variable-container__title">${
          field.alias
        }</div><div class="variable-container__value">${value} ${
          value === "No Data" || !field.units ? "" : field.units
        }</div>`;
        content = content + fieldHtml;
      }      
      return content + "</div>";
    },
    createTwoLayersContentFromXml(xmlDoc, xmlSecondaryDoc) {
      let content = "<div class='variable-container'>";
      for (const field of this.fields) {
        content =
          content +
          `<div class="variable-container__title">${field.alias}</div>`;
        const contentValue = xmlDoc.getElementsByTagName(field.name)[0]
          .textContent;
        const contentSecundaryValue = xmlSecondaryDoc.getElementsByTagName(
          field.name
        )[0].textContent;

        content =
          content +
          this._createTwoLayersFieldHtml(
            field,
            contentValue,
            contentSecundaryValue
          );
      }
      content = content + "</div>";
      return content;
    },
    _createTwoLayersFieldHtml(field, contentValue, contentSecundaryValue) {
      const value = this._getValue(field, contentValue);
      const valueSec = this._getValue(field, contentSecundaryValue);

      const fieldHtml = `<div class="variable-container__value">${value}${
        value !== "No Data" || !field.units ? field.units : ""
      } | ${valueSec}${
        valueSec !== "No Data" || !field.units ? field.units : ""
      }</div>`;

      return fieldHtml;
    },
    _getValue(field, contentValue) {
      let value;
      if (Number.isNaN(parseFloat(contentValue))) {
        value = "No Data";
      } else {
        value = parseFloat(contentValue).toFixed(2);
        if (field.toUnits && field.units === "%") {
          value = value * 100;
        }
      }
      return value;
    }  
  }
}    
</script>
