#' Add Deck.gl ScatterplotLayer to a [mapgl::maplibre()] or [mapgl::mapboxgl()] map
#' using blazing fast [nanoarrow::write_nanoarrow()] data transfer.
#'
#' @param map the [mapgl::maplibre()] or [mapgl::mapboxgl()] map to add the layer to.
#' @param data a sf `(MULTI)POINT` object.
#' @param layer_id the layer id.
#' @param geom_column_name the name of the geometry column of the sf object.
#' It is inferred automatically if only one is present.
#' @param popup should a popup be contructed? If `TRUE`, will create a popup fromm all
#' available attributes of the feature. Can also be a character vector of column
#' names, on which case the popup will include only those columns. If a single character
#' is supplied, then this will be shown for all features. If `NULL` (deafult) or
#' `FALSE`, no popup will be shown.
#' @param tooltip should a tooltip be contructed? If `TRUE`, will create a tooltip fromm all
#' available attributes of the feature. Can also be a character vector of column
#' names, on which case the tooltip will include only those columns. If a single character
#' is supplied, then this will be shown for all features. If `NULL` (deafult) or
#' `FALSE`, no tooltip will be shown.
#' @param render_options a list of [renderOptions]
#' @param data_accessors a list of [dataAccessors]
#' @param popup_options a list of [popupOptions]
#' @param tooltip_options a list of [tooltipOptions]
#' @param ... can be used to pass additional props and parameters to the deck.gl
#' instance. See Details for more info.
#'
#' @details
#' `...` can be used to pass additional props and parameters to the deck.gl instance
#' for fine-tuning rendering behaviour. For example, we can pass a list called
#' `parameters` with settings that control the GPU pipeline of the deck.gl instance.
#' See \url{https://luma.gl/docs/api-reference/core/parameters} for a list of
#' available prarmeters.
#'
#' By default, all deck.gl layers passed to a `maplibre()` map will be drawn on
#' top of existing ones. It is, however, possible to inject layers into existing
#' `maplibre` layers by passing `interleaved = TRUE` via `...`. In combination
#' with a `render_options = renderOptions(beforeId = "<some existing layer-id>")`
#' this will plot the current layer underneath "<some existing layer-id>".
#'
#'
#' @examples
#' library(mapgl)
#' library(sf)
#'
#' n = 5e3
#' dat = data.frame(
#'   id = 1:n
#'   , x = runif(n, -180, 180)
#'   , y = runif(n, -60, 60)
#' )
#' dat = st_as_sf(
#'   dat
#'   , coords = c("x", "y")
#'   , crs = 4326
#' )
#' dat$fillColor = sample(hcl.colors(n, alpha = sample(seq(0, 1, length.out = n))))
#' dat$lineColor = sample(
#'   hcl.colors(n, alpha = sample(seq(0, 1, length.out = n)), palette = "inferno")
#' )
#' dat$radius = sample.int(15, nrow(dat), replace = TRUE)
#' dat$lineWidth = sample.int(5, nrow(dat), replace = TRUE)
#'
#' m = maplibre(
#'   style = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json'
#' ) |>
#'   add_navigation_control(visualize_pitch = TRUE) |>
#'   add_globe_control()
#'
#' m |>
#'   addGeoArrowScatterplotLayer(
#'     data = dat
#'     , layer_id = "test"
#'     , geom_column_name = attr(dat, "sf_column")
#'     , render_options = renderOptions()
#'     , data_accessors = dataAccessors(
#'       getRadius = "radius"
#'       , getFillColor = "fillColor"
#'       , getLineWidth = "lineWidth"
#'       , getLineColor = "lineColor"
#'     )
#'     , parameters = list(
#'       depthCompare = "always"
#'       , cullMode = "back"
#'     )
#'     , popup = TRUE
#'     , popup_options = popupOptions(anchor = "bottom-right")
#'     , tooltip = TRUE
#'     , tooltip_options = tooltipOptions(anchor = "top-left")
#'   )
#'
#' ## interleaved example
#' m |>
#'   addGeoArrowScatterplotLayer(
#'     data = dat
#'     , layer_id = "test"
#'     , geom_column_name = attr(dat, "sf_column")
#'     , interleaved = TRUE
#'     , render_options = renderOptions(beforeId = "boundary_county")
#'     , data_accessors = dataAccessors(
#'       getRadius = "radius"
#'       , getFillColor = "fillColor"
#'       , getLineWidth = "lineWidth"
#'       , getLineColor = "lineColor"
#'     )
#'     , parameters = list(
#'       depthCompare = "always"
#'       , cullMode = "back"
#'     )
#'     , popup = TRUE
#'     , popup_options = popupOptions(anchor = "bottom-right")
#'     , tooltip = TRUE
#'     , tooltip_options = tooltipOptions(anchor = "top-left")
#'   )
#'
#'
#' @export
addGeoArrowScatterplotLayer = function(
    map
    , data
    , layer_id
    , geom_column_name = attr(data, "sf_column")
    , popup = NULL
    , tooltip = NULL
    , render_options = renderOptions()
    , data_accessors = dataAccessors()
    , popup_options = popupOptions()
    , tooltip_options = tooltipOptions()
    , ...
) {

  stopifnot(requireNamespace("geoarrow"))
  UseMethod("addGeoArrowScatterplotLayer")

}


.addGeoArrowScatterplotLayer = function(
    map
    , data
    , layer_id
    , geom_column_name = attr(data, "sf_column")
    , popup = NULL
    , tooltip = NULL
    , render_options = renderOptions()
    , data_accessors = dataAccessors()
    , popup_options = popupOptions()
    , tooltip_options = tooltipOptions()
    , map_class = "maplibregl"
    , js_code
    , ...
) {

  ### TODO: we need a way to render geometries only...!!! sfcs or e.g. wk::...
  # data = try(
  #   sf::st_as_sf(data)
  #   , silent = TRUE
  # )
  #
  # if (inherits(data, "try-error")) {
  #   stop(
  #     "cannot convert data to sf"
  #     , call. = FALSE
  #   )
  # }

  if (isTRUE(popup)) {
    popup = names(data)
  } else if (isFALSE(popup)) {
    popup = NULL
  }

  if (isTRUE(tooltip)) {
    tooltip = names(data)
  } else if (isFALSE(tooltip)) {
    tooltip = NULL
  }

  path_layer = writeGeoarrow(
    data = data
    , path = tempfile()
    , layerId = layer_id
    , geom_column_name
    , interleaved = TRUE
  )

  map$dependencies = c(
    map$dependencies
    , if (!inherits(map, "mapdeck")) deckglDependencies()
  )

  map$dependencies = c(
    map$dependencies
    , list(
      htmltools::htmlDependency(
        name = "deckglScatterplot"
        , version = "0.0.1"
        , src = system.file("htmlwidgets", package = "geoarrowDeckglLayers")
        , script = "addGeoArrowDeckglScatterplotLayer.js"
      )
    )
  )

  map = geoarrowWidget::attachGeoarrowDependencies(
    widget = map
  )

  map$dependencies = c(
    map$dependencies
    , geoarrowDeckglLayersDependencies()
    , helpersDependency()
  )

  map = geoarrowWidget::attachData(
    widget = map
    , file = path_layer
  )

  if (missing(js_code)) {
    js_code = htmlwidgets::JS(
      "function(el, x, data) {
        map = this.getMap();
        addGeoArrowDeckglScatterplotLayer(map, data);
      }"
    )
  }

  default_lst = list(
    geom_column_name = geom_column_name
    , layerId = layer_id
    , popup = popup
    , tooltip = tooltip
    , renderOptions = render_options
    , dataAccessors = data_accessors
    , popupOptions = popup_options
    , tooltipOptions = tooltip_options
    , map_class = map_class
    , interleaved = FALSE
  )

  dot_lst = list(...)

  map = htmlwidgets::onRender(
    map
    , htmlwidgets::JS(js_code)
    , data = utils::modifyList(default_lst, dot_lst)
  )

  return(map)

}

#' @export
addGeoArrowScatterplotLayer.maplibregl = function(
    map
    , data
    , ...
    , map_class = "maplibregl"
) {
  .addGeoArrowScatterplotLayer(
    map
    , data
    , ...
    , map_class = "maplibregl"
  )
}

#' @export
addGeoArrowScatterplotLayer.mapboxgl = function(
    map
    , data
    , ...
    , map_class = "mapboxgl"
  ) {
  .addGeoArrowScatterplotLayer(
    map
    , data
    , ...
    , map_class = "mapboxgl"
  )
}


#' #' @export
#' addGeoArrowScatterplotLayer.mapdeck = function(
#'     map
#'     , data
#'     , ...
#'     , map_class = "mapboxgl"
#' ) {
#'
#'   js_code =
#'     "function(el, x, data) {
#'       debugger;
#'         let data_fl = document.getElementById(data.layer_id + '-1-attachment');
#'
#'         fetch(data_fl.href)
#'           .then(result => Arrow.tableFromIPC(result))
#'           .then(arrow_table => {
#'             let geoArrowScatterplot = scatterplot(x, data, arrow_table);
#'
#'            md_update_layer(el.id, data.layer_id, geoArrowScatterplot);
#'           });
#'       }"
#'
#'   addGeoArrowScatterplotLayer_default(
#'     map
#'     , data
#'     , ...
#'     , map_class = "mapboxgl"
#'     , js_code = js_code
#'   )
#' }
