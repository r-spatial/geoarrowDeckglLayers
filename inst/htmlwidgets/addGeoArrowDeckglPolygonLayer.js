addGeoArrowDeckglPolygonLayer = function(map, opts) {

  let decklayer = new deck.MapboxOverlay({
    interleaved: opts.interleaved,
    layers: [],
  });
  map.addControl(decklayer);

  let data_fl = document.getElementById(opts.layerId + '-geoarrowWidget-attachment');

  fetch(data_fl.href)
    .then(result => Arrow.tableFromIPC(result))
    .then(arrow_table => {

      let polygonlayer = polygonLayer(map, opts, arrow_table);
      decklayer.setProps({layers: polygonlayer});

    });
debugger;
};

polygonLayer = function(map, opts, arrow_table) {
  let gaDeckLayers = window["@geoarrow/deck"]["gl-layers"];

  let layer = new gaDeckLayers.GeoArrowPolygonLayer({
    id: opts.layerId,
    data: arrow_table,
    getPolygon: arrow_table.getChild(opts.geom_column_name),
    beforeId: opts.renderOptions.beforeId,

    // render options
    filled: opts.renderOptions.filled,
    stroked: opts.renderOptions.stroked,
    extruded: opts.renderOptions.extruded,
    wireframe: opts.renderOptions.wireframe,
    elevationScale: opts.renderOptions.elevationScale,
    lineWidthUnits: opts.renderOptions.lineWidthUnits,
    lineWidthScale: opts.renderOptions.lineWidthScale,
    lineWidthMinPixels: opts.renderOptions.lineWidthMinPixels,
    lineWidthMaxPixels: opts.renderOptions.lineWidthMaxPixels,
    lineJointRounded: opts.renderOptions.lineJointRounded,
    lineMiterLimit: opts.renderOptions.lineMiterLimit,
    /*
    material: opts.renderOptions.material,
    _normalize: opts.renderOptions._normalize,
    _windingOrder: opts.renderOptions._windingOrder,
    //https://deck.gl/docs/developer-guide/performance#supply-attributes-directly
    */

    // data accessros
    getFillColor: ({ index, data }) =>
      colorAccessor(index, data, opts.dataAccessors.getFillColor),
    getLineColor: ({ index, data }) =>
      colorAccessor(index, data, opts.dataAccessors.getLineColor),
    getLineWidth: ({ index, data }) =>
      attributeAccessor(index, data, opts.dataAccessors.getLineWidth),
    getElevation: ({ index, data }) =>
      attributeAccessor(index, data, opts.dataAccessors.getElevation),

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
        if (info.picked === false) {
          removePopups("geoarrow-deckgl-tooltip");
        }
        let popup = clickFun(info, event, opts, "tooltip", opts.map_class);
        if (popup !== undefined) {
          popup.addTo(map);
        }
    },

  });

  return layer;

};

/*
        onHover: (info, event) => {
          if (opts.tooltip === null) {
            return;
          }
          if (map.getLayoutProperty(opts.layerId, 'visibility') === 'none') {
            return;
          }
          if (opts.tooltipOptions.length !== 0) {
            //debugger;
            let tooltips = document.getElementsByClassName('geoarrow-deckgl-tooltip');
            for (let i = 0; i < tooltips.length; i++) {
              tooltips[i].remove();
            }
            if (info.picked === false) {
              return;
            }

            let tooltip = new maplibregl.Popup(
              opts.tooltipOptions
            )
            .setLngLat(info.coordinate)
            .setHTML(
              objectToTable(
                info.object,
                className = "",
                opts.tooltip,
                opts.geom_column_name
              )
            );
            tooltip.addTo(map);
          }
        },

      });

      var decklayer = new deck.MapboxOverlay({
        interleaved: true,
        layers: [geoArrowPolygon],
      });
      map.addControl(decklayer);

      if (opts.popup !== null) {
        map.on("click", (e) => {
          //debugger;
          if (map.getLayoutProperty(opts.layerId, 'visibility') === 'none') {
            return;
          }
          let info = e.target.__deck.deckPicker.lastPickedInfo.info;
          if (info === null) {
            return;
          } else {
            let popup = new maplibregl.Popup(
              opts.popupOptions
            )
            .setLngLat(e.lngLat)
            .setHTML(
              objectToTable(
                info.object,
                className = "",
                opts.popup,
                opts.geom_column_name
              )
            );
            popup.addTo(map);
          }
        });
      }

    });
};
*/
