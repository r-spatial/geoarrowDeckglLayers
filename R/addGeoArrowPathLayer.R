#' Add Deck.gl PathLayer to a [mapgl::maplibre()] or [mapgl::mapboxgl()] map
#' using blazing fast [nanoarrow::write_nanoarrow()] data transfer.
#'
#' @param map the [mapgl::maplibre()] or [mapgl::mapboxgl()] map to add the layer to.
#' @param data a sf `(MULTI)LINESTRING` object.
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
#' @param ... currently not used.
#'
#' @export
addGeoArrowPathLayer = function(
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
  UseMethod("addGeoArrowPathLayer")

}

.addGeoArrowPathLayer = function(
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
        name = "deckglPathLayer"
        , version = "0.0.1"
        , src = system.file("htmlwidgets", package = "geoarrowDeckglLayers")
        , script = "addGeoArrowDeckglPathLayer.js"
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
        addGeoArrowDeckglPathLayer(map, data);
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
addGeoArrowPathLayer.maplibregl = function(
    map
    , data
    , ...
) {
  .addGeoArrowPathLayer(
    map
    , data
    , ...
    , map_class = "maplibregl"
  )
}

#' @export
addGeoArrowPathLayer.mapboxgl = function(
    map
    , data
    , ...
) {
  .addGeoArrowPathLayer(
    map
    , data
    , ...
    , map_class = "mapboxgl"
  )
}
