addGeoArrowDeckglPathLayer = function(map, opts) {
  let data_fl = document.getElementById(opts.layerId + '-1-attachment');

  fetch(data_fl.href)
    .then(result => Arrow.tableFromIPC(result))
    .then(arrow_table => {
      let geoArrowPathLayer = pathLayer(map, opts, arrow_table);

      var decklayer = new deck.MapboxOverlay({
        interleaved: true,
        layers: [geoArrowPathLayer],
      });
      map.addControl(decklayer);

    });
};

pathLayer = function(map, opts, arrow_table) {
  let gaDeckLayers = window["@geoarrow/deck"]["gl-layers"];

  let layer = new gaDeckLayers.GeoArrowPathLayer({
    id: opts.layerId,
    data: arrow_table,
    getPath: arrow_table.getChild(opts.geom_column_name),

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

    // data accessros
    getColor: ({ index, data }) => {
      if (typeof(opts.dataAccessors.getColor) === "string") {
        const recordBatch = data.data;
        return hexToRGBA(recordBatch.get(index)[opts.dataAccessors.getColor]);
      } else {
        return opts.dataAccessors.getColor;
      }
    },
    getWidth: ({ index, data }) => {
      if (typeof(opts.dataAccessors.getWidth) === "string") {
        const recordBatch = data.data;
        return recordBatch.get(index)[opts.dataAccessors.getWidth];
      } else {
        return opts.dataAccessors.getWidth;
      }
    },

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
        //views: [new deck.MapView({id: 'maplibregl'})],
        layers: [geoArrowPathLayer],
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
