addGeoArrowDeckglPathLayer = function(map, opts) {

  opts.decklayerId = "deck-layer-group-slot:" + opts.layerId;

  if (opts.renderOptions.beforeId !== null) {
    opts.decklayerId = "deck-layer-group-before:" + opts.renderOptions.beforeId;
  }

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
      const pathlayers = [];
      let len = arrow_table.batches.length;
      let batch = {};
      let id = [];

      for (let i = 0; i < len; i++) {

        batch = arrow_table.batches[i];
        id = `${opts.decklayerId}-${i}`;
        pathlayers.push(pathLayer(map, opts, batch, id));

      }

     // does the mapboxoverlay already have layer(s)?
      if (deckoverlay._props.layers.length ===  0) {
        deckoverlay.setProps({ layers: pathlayers })
      } else {
        let lrs = deckoverlay._props.layers.concat(pathlayers);
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

pathLayer = function(map, opts, table, id) {

  let table_names = table.schema.fields.map(obj => obj.name);

  if (opts.popup === true) {
    opts.popup = table_names;
  }

  if (opts.tooltip === true) {
    opts.tooltip = table_names;
  }

  let layer = new gaDeckLayers.GeoArrowPathLayer({
    //id: opts.decklayerId,
    id: id,
    data: table,
    //getPath: table.getChild(opts.geom_column_name),
    getCursor: () => "inherit",
    beforeId: opts.renderOptions.beforeId,
    slot: opts.layerId,
    zIndex: opts.renderOptions.zIndex,

    // render options
    widthUnits: opts.renderOptions.widthUnits,
    widthScale: opts.renderOptions.widthScale,
    widthMinPixels: opts.renderOptions.widthMinPixels,
    widthMaxPixels: opts.renderOptions.widthMaxPixels,
    capRounded: opts.renderOptions.capRounded,
    jointRounded: opts.renderOptions.jointRounded,
    billboard: opts.renderOptions.billboard,
    miterLimit: opts.renderOptions.miterLimit,
    // _pathType: opts.renderOptions._pathType,

    // data accessors
    getColor: table_names.includes(opts.dataAccessors.getColor) ?
      ({ index, data }) => {
        return colorAccessor(index, data, opts.dataAccessors.getColor);
      } : opts.dataAccessors.getColor === null ? [0,0,0,255] :
        isHexColor(opts.dataAccessors.getColor) ? hexToRGBA(opts.dataAccessors.getColor) :
          opts.dataAccessors.getColor,

    getWidth: table_names.includes(opts.dataAccessors.getWidth) ?
      ({ index, data }) => {
        return attributeAccessor(index, data, opts.dataAccessors.getWidth);
      } : opts.dataAccessors.getWidth === null ? 1 : opts.dataAccessors.getWidth,

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
