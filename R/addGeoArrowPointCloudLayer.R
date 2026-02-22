# #' Add Deck.gl PointCloudLayer to a [mapgl::maplibre()] or [mapgl::mapboxgl()] map
# #' using blazing fast [nanoarrow::write_nanoarrow()] data transfer.
# #'
# #' @param map the [mapgl::maplibre()] or [mapgl::mapboxgl()] map to add the layer to.
# #' @param data a sf `(MULTI)POINT` object.
# #' @param layerId the layer id.
# #' @param geom_column_name the name of the geometry column of the sf object.
# #' It is inferred automatically if only one is present.
# #' @param popup should a popup be contructed? If `TRUE`, will create a popup fromm all
# #' available attributes of the feature. Can also be a character vector of column
# #' names, on which case the popup will include only those columns. If a single character
# #' is supplied, then this will be shown for all features. If `NULL` (deafult) or
# #' `FALSE`, no popup will be shown.
# #' @param tooltip should a tooltip be contructed? If `TRUE`, will create a tooltip fromm all
# #' available attributes of the feature. Can also be a character vector of column
# #' names, on which case the tooltip will include only those columns. If a single character
# #' is supplied, then this will be shown for all features. If `NULL` (deafult) or
# #' `FALSE`, no tooltip will be shown.
# #' @param render_options a list of [renderOptions]
# #' @param data_accessors a list of [dataAccessors]
# #' @param popup_options a list of [popupOptions]
# #' @param tooltip_options a list of [tooltipOptions]
# #' @param ... currently not used.
# #'
# #' @examples
# #' library(mapgl)
# #' library(sf)
# #'
# #' n = 5e3
# #' dat = data.frame(
# #'   id = 1:n
# #'   , x = runif(n, -180, 180)
# #'   , y = runif(n, -60, 60)
# #'   , z = runif(n, 200, 600)
# #' )
# #' dat = st_as_sf(
# #'   dat
# #'   , coords = c("x", "y", "z")
# #'   , crs = 4326
# #' )
# #' dat$fillColor = sample(hcl.colors(n, alpha = sample(seq(0, 1, length.out = n))))
# #' dat$lineColor = sample(
# #'   hcl.colors(n, alpha = sample(seq(0, 1, length.out = n)), palette = "inferno")
# #' )
# #' dat$radius = sample.int(15, nrow(dat), replace = TRUE)
# #' dat$lineWidth = sample.int(5, nrow(dat), replace = TRUE)
# #'
# #' m = maplibre(
# #'   style = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json'
# #' ) |>
# #'   add_navigation_control(visualize_pitch = TRUE) |>
# #'   add_layers_control(collapsible = TRUE, layers = c("test"))
# #'
# #' m |>
# #'   addGeoArrowPointCloudLayer(
# #'     data = dat
# #'     , layerId = "test"
# #'     , geom_column_name = attr(dat, "sf_column")
# #'     , render_options = renderOptions()
# #'     , data_accessors = dataAccessors(
# #'       getRadius = "radius"
# #'       , getFillColor = "fillColor"
# #'       , getLineWidth = "lineWidth"
# #'       , getLineColor = "lineColor"
# #'     )
# #'     , popup = TRUE
# #'     , popup_options = popupOptions(anchor = "bottom-right")
# #'     , tooltip = TRUE
# #'     , tooltip_options = tooltipOptions(anchor = "top-left")
# #'   )
# #'
# #' @export
addGeoArrowPointCloudLayer = function(
    map
    , data
    , layerId
    , geom_column_name = attr(data, "sf_column")
    , popup = NULL
    , tooltip = NULL
    , render_options = renderOptions()
    , data_accessors = dataAccessors()
    , popup_options = popupOptions()
    , tooltip_options = tooltipOptions()
    , ...
) {

  UseMethod("addGeoArrowPointCloudLayer")

}


addGeoArrowPointCloudLayer_default = function(
    map
    , data
    , layerId
    , geom_column_name = attr(data, "sf_column")
    , popup = NULL
    , tooltip = NULL
    , render_options = renderOptions()
    , data_accessors = dataAccessors()
    , popup_options = popupOptions()
    , tooltip_options = tooltipOptions()
    , map_class = "maplibregl"
    , js_code
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

  if (missing(js_code)) {
    js_code = htmlwidgets::JS(
      "function(el, x, data) {
        map = this.getMap();
        addGeoArrowDeckglPointCloudLayer(map, data);
      }"
    )
  }

  path_layer = writeGeoarrow(data, layerId, geom_column_name)

  map$dependencies = c(
    map$dependencies
    , list(
      htmltools::htmlDependency(
        name = "globeControl"
        , version = "0.0.1"
        , src = system.file("htmlwidgets", package = "geoarrowDeckglLayers")
        , script = "globeControl.js"
      )
    )
    , list(
      htmltools::htmlDependency(
        name = "deckglPointCloud"
        , version = "0.0.1"
        , src = system.file("htmlwidgets", package = "geoarrowDeckglLayers")
        , script = "addGeoArrowDeckglPointCloudLayer.js"
      )
    )
    , arrowDependencies()
    , geoarrowjsDependencies()
    , if (!inherits(map, "mapdeck")) deckglDependencies()
    , geoarrowDeckglLayersDependencies()
    , deckglDataAttachmentSrc(path_layer, layerId)
    # , deckglMapboxDependency()
    , helpersDependency()
  )

  map = htmlwidgets::onRender(
    map
    , htmlwidgets::JS(js_code)
    , data = list(
      geom_column_name = geom_column_name
      , layerId = layerId
      , popup = popup
      , tooltip = tooltip
      , renderOptions = render_options
      , dataAccessors = data_accessors
      , popupOptions = popup_options
      , tooltipOptions = tooltip_options
      , map_class = map_class
    )
  )

  return(map)

}

#' @export
addGeoArrowPointCloudLayer.maplibregl = function(
    map
    , data
    , ...
    , map_class = "maplibregl"
) {
  addGeoArrowPointCloudLayer_default(
    map
    , data
    , ...
    , map_class = "maplibregl"
  )
}

#' @export
addGeoArrowPointCloudLayer.mapboxgl = function(
    map
    , data
    , ...
    , map_class = "mapboxgl"
) {
  addGeoArrowPointCloudLayer_default(
    map
    , data
    , ...
    , map_class = "mapboxgl"
  )
}
