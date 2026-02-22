addGeoArrowDeckglScatterplotLayer = function(map, opts) {

  let data_fl = document.getElementById(opts.layerId + '-geoarrowWidget-attachment');

  fetch(data_fl.href)
    .then(result => Arrow.tableFromIPC(result))
    .then(arrow_table => {

      let geoArrowScatterplot = scatterplotLayer(map, opts, arrow_table);

      let decklayer = new deck.MapboxOverlay({
        interleaved: true,
        layers: [geoArrowScatterplot],
      });
      map.addControl(decklayer);
    });
};


scatterplotLayer = function(map, opts, arrow_table) {
  let gaDeckLayers = window["@geoarrow/deck"]["gl-layers"];

  let layer = new gaDeckLayers.GeoArrowScatterplotLayer({
    id: opts.layerId,
    // FIXME: have a look at https://github.com/geoarrow/deck.gl-layers/blob/main/examples/point/app.tsx#L53-L71
    // for potential update to new batch based rendering in deck.gl-layers
    data: arrow_table.batches[0],
    getPosition: arrow_table.batches[0].getChild(opts.geom_column_name),

    // render options
    radiusUnits: opts.renderOptions.radiusUnits,
    radiusScale: opts.renderOptions.radiusScale,
    lineWidthUnits: opts.renderOptions.lineWidthUnits,
    lineWidthScale: opts.renderOptions.lineWidthScale,
    stroked: opts.renderOptions.stroked,
    filled: opts.renderOptions.filled,
    radiusMinPixels: opts.renderOptions.radiusMinPixels,
    radiusMaxPixels: opts.renderOptions.radiusMaxPixels,
    lineWidthMinPixels: opts.renderOptions.lineWidthMinPixels,
    lineWidthMaxPixels: opts.renderOptions.lineWidthMaxPixels,
    billboard: opts.renderOptions.billboard,
    antialiasing: opts.renderOptions.antialiasing,

    // data accessros
    getRadius: ({ index, data }) =>
      attributeAccessor(index, data, opts.dataAccessors.getRadius),
    getFillColor: ({ index, data }) =>
      colorAccessor(index, data, opts.dataAccessors.getFillColor),
    getLineColor: ({ index, data }) =>
      colorAccessor(index, data, opts.dataAccessors.getLineColor),
    getLineWidth: ({ index, data }) =>
      attributeAccessor(index, data, opts.dataAccessors.getLineWidth),

    // interactivity
    pickable: true,

    // GPU parameters (from luma.gl)
    // see https://luma.gl/docs/api-reference/core/parameters for valid params
    // this is currently mainly used to set 'depthCompare: "always"' to avoid
    // z-fighting rendering issues. Passed via ... from R currently.
    // (see https://github.com/developmentseed/lonboard/issues/1037)
    parameters: opts.parameters,

    onClick: (info, event) => {
        let popup = clickFun(info, event, opts, "popup", opts.map_class);
        if (popup !== undefined) {
          popup.addTo(map);
        }
    },

    onHover: (info, event) => {
      //debugger;
        if (info.picked === false) {
          removePopups("geoarrow-deckgl-tooltip");
        }
        let popup = clickFun(info, event, opts, "tooltip", opts.map_class);
        if (popup !== undefined) {
          popup.addTo(map);
        }
        //console.log(map.getProjection());
        // unfortunately the following does not switch between globe and mercator
        // mode for the tooltips. It doesn't expand the pickable area to the
        // mercator area.
        /*
        let globeEnabled = document.getElementsByClassName("maplibregl-ctrl-globe-enabled");
        if (globeEnabled.length === 1) {
          Object.assign(info.sourceLayer.props.parameters, {cullMode: 'back'});
          console.log(info.sourceLayer.props.parameters);
        }
        if (globeEnabled.length === 0) {
          Object.assign(info.sourceLayer.props.parameters, {cullMode: 'none'});
          console.log(info.sourceLayer.props.parameters);
        }
        */
    },

  });

  return layer;

};
