addGeoArrowDeckglScatterplotLayer = function(map, opts) {

  // FIXME: turn into function for re-use across layer types
  // first we generate the proper internal layer name using the slot parameter
  opts.decklayerId = "deck-layer-group-slot:" + opts.layerId;

  // then, if 'beforeId' is supplied we change accordingly. see
  // https://github.com/visgl/deck.gl/tree/master/modules/mapbox/src/resolve-layer-groups.ts#L13-L20
  if (opts.renderOptions.beforeId !== null) {
    opts.decklayerId = "deck-layer-group-before:" + opts.renderOptions.beforeId;
  }

  // FIXME: turn into function for re-use across layer types
  // do we already have a deckgl mapboxoverlay on our map?
  let deckoverlay = map._controls.find((el) => el.hasOwnProperty("_deck"));

  if (deckoverlay === undefined) {
    deckoverlay = new MapboxOverlay({
      id: "geoarrow-deck-layer",
      interleaved: opts.interleaved,
      layers: [],
      getCursor: ({ isHovering }) => (isHovering ? 'pointer' : 'grab'),
      deviceProps: {
        _cacheShaders: true,
        _cachePipelines: true,
      }
    });
    map.addControl(deckoverlay);
  }

  // find the attached arrow data, fetch and inject into the mapboxoverlay
  let data_fl = document.getElementById(opts.layerId + '-geoarrowWidget-attachment');

  opts.extension_type = guessExtension(data_fl.href);

  fetch(data_fl.href)
    .then(result => {
      if (opts.extension_type === "arrow") {
        return Arrow.tableFromIPC(result);
      } else if (opts.extension_type === "parquet") {
        return window.parquet2arrow(result);
      } else {
        console.warn("extension type not supported, need 'geoarrow' or 'geoparquet'");
      }
    })
    .then(arrow_table => {

      let batchIndex = 0;
      const scatterlayers = [];
      let len = arrow_table.batches.length;
      let batch = {};
      let id = [];

      for (let i = 0; i < len; i++) {

        batch = arrow_table.batches[i];
        id = `${opts.decklayerId}-${i}`;
        scatterlayers.push(scatterplotLayer(map, opts, batch, id));

      }

      // does the mapboxoverlay already have layer(s)?
      if (deckoverlay._props.layers.length ===  0) {
        deckoverlay.setProps({ layers: scatterlayers });
      } else {
        let lrs = deckoverlay._props.layers.concat(scatterlayers);
        lrs = lrs.sort(function(a, b) {
          return a.props.zIndex - b.props.zIndex;
        });
        deckoverlay.setProps({ layers: lrs });
      }

    });

  map.on("projectiontransition", () => {
    deckoverlay._updateViewState();
  });

};


scatterplotLayer = function(map, opts, table, id) {

  let table_names = table.schema.fields.map(obj => obj.name);

  if (opts.popup === true) {
    opts.popup = table_names;
  }

  if (opts.tooltip === true) {
    opts.tooltip = table_names;
  }

  let layer = new gaDeckLayers.GeoArrowScatterplotLayer({
    //id: opts.decklayerId,
    id: id,
    data: table,
    //getPosition: table.getChild(opts.geom_column_name),
    beforeId: opts.renderOptions.beforeId,
    slot: opts.layerId,
    zIndex: opts.renderOptions.zIndex,

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

    // data accessors
    getRadius: table_names.includes(opts.dataAccessors.getRadius) ?
      ({ index, data }) => {
        return attributeAccessor(index, data, opts.dataAccessors.getRadius);
      } : opts.dataAccessors.getRadius === null ? 1 : opts.dataAccessors.getRadius,

    getFillColor: table_names.includes(opts.dataAccessors.getFillColor) ?
      ({ index, data }) => {
        return colorAccessor(index, data, opts.dataAccessors.getFillColor);
      } : opts.dataAccessors.getFillColor === null ? [0,0,0,255] :
        isHexColor(opts.dataAccessors.getFillColor) ? hexToRGBA(opts.dataAccessors.getFillColor) :
          opts.dataAccessors.getFillColor,

    getLineColor: table_names.includes(opts.dataAccessors.getLineColor) ?
      ({ index, data }) => {
        return colorAccessor(index, data, opts.dataAccessors.getLineColor);
      } : opts.dataAccessors.getLineColor === null ? [0,0,0,255] :
        isHexColor(opts.dataAccessors.getLineColor) ? hexToRGBA(opts.dataAccessors.getLineColor) :
          opts.dataAccessors.getLineColor,

    getLineWidth: table_names.includes(opts.dataAccessors.getLineWidth) ?
      ({ index, data }) => {
        return attributeAccessor(index, data, opts.dataAccessors.getLineWidth);
      } : opts.dataAccessors.getLineWidth === null ? 1 : opts.dataAccessors.getLineWidth,

    // interactivity
    pickable: opts.pickable,

    // GPU parameters (from luma.gl)
    // see https://luma.gl/docs/api-reference/core/parameters for valid params
    // this is currently mainly used to set 'depthCompare: "always"' to avoid
    // z-fighting rendering issues. Passed via ... from R currently.
    // (see https://github.com/developmentseed/lonboard/issues/1037)
    parameters: opts.parameters,

    onClick: opts.popup === null ? null : (info, event) => {
        let popup = clickFun(info, event, opts, "popup", opts.map_class);
        if (popup !== undefined) {
          popup.addTo(map);
        }
    },

    onHover: opts.tooltip === null ? null : (info, event) => {
      console.log(event.object);
        if (info.picked === false) {
          removePopups(opts.tooltipOptions.className);
        }
        let popup = clickFun(info, event, opts, "tooltip", opts.map_class);
        if (popup !== undefined) {
          popup.addTo(map);
        }
    },

  });

  return layer;

};
