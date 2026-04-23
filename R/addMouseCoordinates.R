addMouseCoordinates <- function(map,
                                epsg = NULL,
                                proj4string = NULL,
                                native.crs = FALSE,
                                css = list()) {

  if (native.crs) { # | map$x$options$crs$crsClass == "L.CRS.Simple") {
    txt_detailed <- paste0("
                           ' x: ' + (e.lngLat.lng).toFixed(5) +
                           ' | y: ' + (e.lngLat.lat).toFixed(5) +
                           ' | epsg: ", epsg, " ' +
                           ' | proj4: ", proj4string, " ' +
                           ' | zoom: ' + map.getZoom() + ' '")
  } else {
    txt_detailed <- paste0("
                           ' lon: ' + (e.lngLat.lng).toFixed(5) +
                           ' | lat: ' + (e.lngLat.lat).toFixed(5) +
                           ' | zoom: ' + map.getZoom() +
                           ' | x: ' + L.CRS.EPSG3857.project(e.lngLat).x.toFixed(0) +
                           ' | y: ' + L.CRS.EPSG3857.project(e.lngLat).y.toFixed(0) +
                           ' | epsg: 3857 ' +
                           ' | proj4: +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs '")
  }

  txt_basic <- paste0("
                      ' lon: ' + (e.lngLat.lng).toFixed(5) +
                      ' | lat: ' + (e.lngLat.lat).toFixed(5) +
                      ' | zoom: ' + map.getZoom().toFixed(3) + ' '")

  # map$dependencies = c(
  #   map$dependencies,
  #   clipboardDependency()
  # )

  css_dflt = list(
    'position' = 'relative'
    , 'bottomleft' =  '0px'
    , 'background-color' = 'rgba(255, 255, 255, 0.7)'
    , 'box-shadow' = '0 0 2px #bbb'
    , 'background-clip' = 'padding-box'
    , 'margin' = '0'
    , 'padding-left' = '5px'
    , 'padding-right' = '5px'
    , 'color' = '#333'
    , 'font-size' = '9px'
    , 'font-family' = '\"Helvetica Neue\", Arial, Helvetica, sans-serif'
    , 'text-align' = 'left'
    , 'z-index' = '700'
  )

  css = utils::modifyList(css_dflt, css)

  map <- htmlwidgets::onRender(
    map,
    paste0(
      "
      function(el, x, data) {
      // get the map
      map = this.getMap(); //HTMLWidgets.find('#' + el.id);
      // we need a new div element because we have to handle
      // the mouseover output separately
      debugger;
      function addElement () {
        // generate new div Element
        var newDiv = document.createElement('div');
        // append at end of leaflet htmlwidget container
        el.append(newDiv);
        //provide ID and style
        newDiv.class = '.lnlt';
        newDiv.id = 'lnlt';
        Object.assign(newDiv.style, ", jsonlite::toJSON(css, auto_unbox = TRUE), ");
        return newDiv;
      }


      // check for already existing lnlt class to not duplicate
      var lnlt = document.getElementById('lnlt');

      if(!lnlt) {
        lnlt = addElement();

        // grab the special div we generated in the beginning
        // and put the mousmove output there

        map.on('mousemove', function (e) {
        debugger;
          if (e.originalEvent.ctrlKey) {
            if (document.querySelector('.lnlt') === null) lnlt = addElement();
            lnlt.text(", txt_detailed, ");
          } else {
            if (document.getElementById('lnlt') === null) lnlt = addElement();
            lnlt.innerHTML = ", txt_basic, ";
          }
        });

        // remove the lnlt div when mouse leaves map
        map.on('mouseout', function (e) {
          var strip = document.querySelector('.lnlt');
          if( strip !==null) strip.remove();
        });

      };

      //$(el).keypress(67, function(e) {
        map.on('preclick', function(e) {
          if (e.originalEvent.ctrlKey) {
            if (document.querySelector('.lnlt') === null) lnlt = addElement();
            lnlt.text(", txt_basic, ");
            var txt = document.querySelector('.lnlt').textContent;
            console.log(txt);
            //txt.innerText.focus();
            //txt.select();
            setClipboardText('\"' + txt + '\"');
          }
        });

      }
      "
    )
  )
  return(map)
}
