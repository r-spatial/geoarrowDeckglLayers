#' Add Deck.gl S2Layer to a [mapgl::maplibre()] or [mapgl::mapboxgl()] map
#' using blazing fast [nanoarrow::write_nanoarrow()] data transfer.
#'
#' @param map the [mapgl::maplibre()] or [mapgl::mapboxgl()] map to add the layer to.
#' @param data a `sf`, `wk`, `geos` or `SpatVector` `(MULTI)POLYGON` object.
#' Ignored if `source` is supplied.
#' @param source the `id` of a source previously added via [addSource()].
#' @param file a valid local file path to a `geoarrow` or `geoparquet` file to be
#' added to the map. Ignored if `source` or `data` is supplied.
#' @param url a URL to a remotely hosted `geoarrow` or `geoparquet` file to be
#' added to the map. Ignored if `source` or `data` or `file` is supplied.
#' @param layer_id the layer id.
#' @param s2_column_name the name of the S2 cells column of the data object.
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
#' top of existing ones. It is, however, possible to inject layers into the
#' existing `maplibre` (base) layer stack by using
#' `render_options = renderOptions(beforeId = "<some-existing-layer-id>")`
#' which will plot the current layer underneath `"<some-existing-layer-id>"`.
#' See below for an example.
#'
#' @return The modified \code{map} object with the added polygon layer.
#'
#' @examples
#' library(wk)
#' library(s2)
#' library(mapgl)
#'
#' ## global coverage at S2 level 3
#' n = 1e5
#'
#' pts = data.frame(
#'   id = seq_len(n)
#'   , geometry = xy(
#'     x = runif(n, -180, 180)
#'     , y = runif(n, -90, 90)
#'     , crs = 4326
#'   )
#' )
#'
#' pts$s2cell = as_s2_cell(pts$geometry)
#' pts$s2parent_l4 = as.character(s2_cell_parent(pts$s2cell, level = 3))
#' pts$s2cell = as.character(pts$s2cell)
#'
#' sbs = pts[!duplicated(pts$s2parent_l4), ]
#'
#' style_positron = "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json"
#'
#' m = maplibre(style = style_positron)
#'
#' m |>
#'   addGeoArrowS2Layer(
#'     data = sbs
#'     , layer_id = "s2layer"
#'     , s2_column_name = "s2parent_l4"
#'     , data_accessors = dataAccessors(
#'       getFillColor = "#74aa2380"
#'       , getLineColor = "#4523bb"
#'       , getLineWidth = 2
#'     )
#'   ) |>
#'   set_view(c(0, 0), 2) |>
#'   add_globe_control() |>
#'   add_navigation_control(visualize_pitch = TRUE)
#'
#' ## S2 hierarchy for one point
#' dat = data.frame(
#'   token = as.character(
#'     s2_cell_parent(
#'       as_s2_cell(
#'         s2_lnglat(-75.7019612, 45.4186427)
#'       )
#'       , level = 1:30
#'     )
#'   )
#'   , elevation = seq(10, 1000, length.out = 30)
#'   , fillColor = hcl.colors(30, palette = "inferno", alpha = 0.1)
#' )
#'
#' m = maplibre()
#'
#' m |>
#'   addGeoArrowS2Layer(
#'     data = dat
#'     , layer_id = "s2layer"
#'     , s2_column_name = "token"
#'     , render_options = renderOptions(
#'       extruded = TRUE
#'       , wireframe = TRUE
#'     )
#'     , data_accessors = dataAccessors(
#'       getFillColor = "fillColor"
#'       , getElevation = "elevation"
#'     )
#'   ) |>
#'   set_view(c(-45, 45), 1) |>
#'   add_globe_control() |>
#'   add_navigation_control(visualize_pitch = TRUE)
#'
#' @export
addGeoArrowS2Layer = function(
    map
    , data
    , source
    , file
    , url
    , layer_id = "s2"
    , s2_column_name = "s2_cells"
    , popup = NULL
    , tooltip = NULL
    , render_options = renderOptions()
    , data_accessors = dataAccessors()
    , popup_options = popupOptions()
    , tooltip_options = tooltipOptions()
    , ...
) {

  UseMethod("addGeoArrowS2Layer")

}

.addGeoArrowS2Layer = function(
    map
    , data
    , source
    , file
    , url
    , layer_id = "s2"
    , s2_column_name = "s2_cells"
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

  stopifnot(requireNamespace("geoarrow", quietly = TRUE))

  map$dependencies = c(
    map$dependencies
    , importDependencies()
    , deckglgeoarrowModuleDependency()
    , helpersDependency()
  )

  map = geoarrowWidget::attachParquetWasmDependencies(
    widget = map
  )

  map$dependencies = c(
    map$dependencies
    , list(
      htmltools::htmlDependency(
        name = "deckglS2Layer"
        , version = "0.0.1"
        , src = system.file("htmlwidgets", package = "deckglgeoarrow")
        , script = "addGeoArrowDeckglS2Layer.js"
      )
    )
  )

  if (missing(source)) {
    map = addSource(
      map = map
      , data = data
      , file = file
      , url = url
      , id = layer_id
    )
  } else {
    layer_id = source
  }

  if (missing(js_code)) {
    js_code = htmlwidgets::JS(
      "function(el, x, data) {
        map = this.getMap();
        addGeoArrowDeckglS2Layer(map, data);
      }"
    )
  }

  if (isFALSE(popup)) {
    popup = NULL
  }

  if (isFALSE(tooltip)) {
    tooltip = NULL
  }

  default_lst = list(
    s2_column_name = s2_column_name
    , layerId = layer_id
    , popup = popup
    , tooltip = tooltip
    , renderOptions = render_options
    , dataAccessors = data_accessors
    , popupOptions = popup_options
    , tooltipOptions = tooltip_options
    , parameters = list(
      depthCompare = "always"
      , cullMode = "back"
    )
    , map_class = map_class
    , interleaved = TRUE
    , pickable = any(pickable(popup), pickable(tooltip))
  )

  dot_lst = list(...)

  map = htmlwidgets::onRender(
    map
    , htmlwidgets::JS(js_code)
    , data = utils::modifyList(default_lst, dot_lst, keep.null = TRUE)
  )

  return(map)

}

#' @export
addGeoArrowS2Layer.maplibregl = function(
    map
    , ...
) {
  .addGeoArrowS2Layer(
    map
    , ...
    , map_class = "maplibregl"
  )
}

#' @export
addGeoArrowS2Layer.mapboxgl = function(
    map
    , ...
) {
  .addGeoArrowS2Layer(
    map
    , ...
    , map_class = "mapboxgl"
  )
}
