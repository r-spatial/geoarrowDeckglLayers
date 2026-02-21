function objectToTable(obj, className, columns, geom_column_name) {

  if (columns === undefined) {
    return;
  }

  let cols = Object.keys(obj);
  let vals = Object.values(obj);
  let tab = "";

  let idx = [];
  if (typeof(columns) === "object") {
    columns.forEach(name => {idx.push(cols.indexOf(name))});
  }
  if (typeof(columns) === "string") {
    idx.push(cols.indexOf(columns));
  }

  if (idx[0] === -1) { // popup string not a table column name?
    // return "<a class=" + className + ">" + columns + "</a>";
    return columns;
  }

  let cls = [];
  idx.forEach(id => { cls.push(cols.at(id)) });
  let vls = [];
  idx.forEach(id => { vls.push(vals.at(id)) });

  for (let i = 0; i < cls.length; i++) {
    if (cls[i] === geom_column_name) {
        continue;
    }
    tab += "<tr><th align='left'>" + cls[i] + "&emsp;</th>" +
    "<td align='right'>" + vls[i] + "&emsp;</td></tr>";
  }
  return "<table class=" + className + ">" + tab + "</table>";
}


function hexToRGBA(hex) {
    // remove invalid characters
    hex = hex.replace(/[^0-9a-fA-F]/g, '');

    if (hex.length < 5) {
        // 3, 4 characters double-up
        hex = hex.split('').map(s => s + s).join('');
    }

    // parse pairs of two
    let rgba = hex.match(/.{1,2}/g).map(s => parseInt(s, 16));

    // alpha code between 0 & 1 / default 1
    //rgba[3] = rgba.length > 3 ? parseFloat(rgba[3] / 255).toFixed(2): 1;

    return rgba; //'rgba(' + rgba.join(', ') + ')';
}

function isHexColor(string) {
  let reg = /^#([0-9A-F]{3}){1,2}[0-9a-f]{0,2}$/i;
  return reg.test(string);
}

function colorAccessor(index, data, color)  {
  if (isHexColor(color)) {
    return hexToRGBA(color);
  }
  if (typeof(color) === "string") {
    const recordBatch = data.data;
    return hexToRGBA(recordBatch.get(index)[color]);
  }
  return color;
}

function attributeAccessor(index, data, property) {
  if (typeof(property) === "string") {
    const recordBatch = data.data;
    return recordBatch.get(index)[property];
  } else {
    return property;
  }
}

function clickFun (info, event, opts, type, map_class) {

  let typeOptions = "popupOptions";
  if (type === "tooltip") {
    typeOptions = "tooltipOptions";
  }

  if (opts[type] === null) {
    return;
  }
  if (map.getLayoutProperty(opts.layerId, 'visibility') === 'none') {
    return;
  }
  if (info.picked === false) {
    return;
  }

  if (opts[typeOptions].length !== 0) {
  //debugger;
    removePopups(opts[typeOptions].className);
//debugger;
    let popup = new window[map_class].Popup(
      opts[typeOptions]
    )
    .setLngLat(info.coordinate)
    .setHTML(
      objectToTable(
        info.object,
        className = "",
        opts[type],
        opts.geom_column_name
      )
    );

    if (type === "tooltip") {
      popup._content.style.setProperty("pointer-events", "none");
    }

    /*
    let globeEnabled = document.getElementsByClassName("maplibregl-ctrl-globe-enabled");
    if (globeEnabled.length === 1) {
      Object.assign(opts.parameters, {cullMode: 'back'});
      console.log(info);
    }
    if (globeEnabled.length === 0) {
      Object.assign(opts.parameters, {cullMode: 'none'});
      console.log(info);
    }
    */

    return popup;
  }
}

function removePopups(className) {
  let popups = document.getElementsByClassName(className);
  if (popups.length > 0) {
    for (let i = 0; i < popups.length; i++) {
      popups[i].remove();
    }
  }
}
