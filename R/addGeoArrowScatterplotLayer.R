#' Add Deck.gl ScatterplotLayer to a [mapgl::maplibre()] or [mapgl::mapboxgl()] map
#' using blazing fast [nanoarrow::write_nanoarrow()] data transfer.
#'
#' @param map the [mapgl::maplibre()] or [mapgl::mapboxgl()] map to add the layer to.
#' @param data a `sf`, `wk`, `geos` or `SpatVector` `(MULTI)POINT` object.
#' Ignored if `source` is supplied.
#' @param source the `id` of a source previously added via [addSource()].
#' @param file a valid local file path to a `geoarrow` or `geoparquet` file to be
#' added to the map. Ignored if `source` or `data` is supplied.
#' @param url a URL to a remotely hosted `geoarrow` or `geoparquet` file to be
#' added to the map. Ignored if `source` or `data` or `file` is supplied.
#' @param layer_id the layer id.
#' @param geom_column_name the name of the geometry column of data object.
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
#' top of existing ones. It is, however, possible to inject layers into the
#' existing `maplibre` (base) layer stack by using
#' `render_options = renderOptions(beforeId = "<some-existing-layer-id>")`
#' which will plot the current layer underneath `"<some-existing-layer-id>"`.
#' See below for an example.
#'
#' @return The modified \code{map} object with the added scatterplot layer.
#'
#' @examples
#' library(wk)
#' library(mapgl)
#'
#' style_positron = "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json"
#'
#' m = maplibre(style = style_positron)
#'
#' ## single wk POINT
#' pt = wkt("POINT (0 0)")
#'
#' m |>
#'   addGeoArrowScatterplotLayer(
#'     data = pt
#'     , layer_id = "wk_point"
#'   )
#'
#' ## wk POINT data frame
#' n = 5e3
#'
#' pts = xy(
#' x = runif(n, -180, 180)
#' , y = runif(n, -50, 50)
#' , crs = 4326
#' )
#'
#' dat = data.frame(
#'   id = 1:length(pts)
#'   , geometry = pts
#' )
#'
#' dat$fillColor = sample(hcl.colors(n, alpha = sample(seq(0, 1, length.out = n))))
#' dat$lineColor = sample(
#'   hcl.colors(n, alpha = sample(seq(0, 1, length.out = n)), palette = "inferno")
#' )
#' dat$radius = sample.int(15, nrow(dat), replace = TRUE)
#' dat$lineWidth = sample.int(5, nrow(dat), replace = TRUE)
#'
#' m = maplibre(
#'   style = style_positron
#' ) |>
#'   add_navigation_control(visualize_pitch = TRUE) |>
#'   add_globe_control()
#'
#' m |>
#'   addGeoArrowScatterplotLayer(
#'     data = dat
#'     , layer_id = "wk-points-layer"
#'     , geom_column_name = "geometry"
#'     , render_options = renderOptions()
#'     , data_accessors = dataAccessors(
#'       getRadius = "radius"
#'       , getFillColor = "fillColor"
#'       , getLineWidth = "lineWidth"
#'       , getLineColor = "lineColor"
#'     )
#'     , popup = TRUE
#'     , popup_options = popupOptions(anchor = "bottom-right")
#'     , tooltip = TRUE
#'     , tooltip_options = tooltipOptions(anchor = "top-left")
#'   )
#'
#' ## same as above, but using `beforeId` to inject layer into base layer stack
#' m |>
#'   addGeoArrowScatterplotLayer(
#'     data = dat
#'     , layer_id = "wk-points-layer-before-water"
#'     , geom_column_name = "geometry"
#'     , render_options = renderOptions(beforeId = "water")
#'     , data_accessors = dataAccessors(
#'       getRadius = "radius"
#'       , getFillColor = "fillColor"
#'       , getLineWidth = "lineWidth"
#'       , getLineColor = "lineColor"
#'     )
#'     , popup = TRUE
#'     , popup_options = popupOptions(anchor = "bottom-right")
#'     , tooltip = FALSE
#'     , tooltip_options = tooltipOptions(anchor = "top-left")
#'   )
#'
#' ## remote parquet file
#' ## paste url together so CRAN check doesn't complain
#' base_url = "https://raw.githubusercontent.com/geoarrow/"
#' data_url = "geoarrow-data/v0.2.0/natural-earth/files/natural-earth_cities_native.parquet"
#' url = paste0(base_url, data_url)
#'
#' m |>
#'   addGeoArrowScatterplotLayer(
#'     url = url
#'     , layer_id = "parquet-layer"
#'     , geom_column_name = "geometry"
#'     , data_accessors = dataAccessors(
#'       getRadius = 10
#'       , getFillColor = '#ff000090'
#'       , getLineColor = '#000000ff'
#'     )
#'     , tooltip = TRUE
#'   )
#'
#' @tests tinytest
#'
#' dummy_map <- structure(
#'   list(dependencies = list(), x = list()),
#'   class = "maplibregl"
#' )
#'
#' ## -----------------------------------------------------------------------
#' ## 1. Default argument values
#' ## -----------------------------------------------------------------------
#' # Confirm the formals carry the documented defaults so callers can rely on
#' # them without spelling them out.
#'
#' f = formals(addGeoArrowScatterplotLayer)
#' expect_equal(f[["layer_id"]], "scatter")
#' expect_equal(f[["geom_column_name"]], "geometry")
#' expect_null(f[["popup"]])
#' expect_null(f[["tooltip"]])
#'
#' ## -----------------------------------------------------------------------
#' ## 2. Function is a generic (S3 dispatch)
#' ## -----------------------------------------------------------------------
#'
#' # addGeoArrowScatterplotLayer must be an S3 generic so that maplibregl and
#' # mapboxgl map objects dispatch to the right method.
#'
#' expect_true(isS3stdGeneric(addGeoArrowScatterplotLayer))
#'
#' # Both concrete methods must be registered.
#'
#' expect_true(
#'  "addGeoArrowScatterplotLayer.maplibregl" %in% ls(getNamespace("deckglgeoarrow"))
#' )
#' expect_true(
#'  "addGeoArrowScatterplotLayer.mapboxgl"   %in% ls(getNamespace("deckglgeoarrow"))
#' )
#'
#' ## -----------------------------------------------------------------------
#' ## 3. All relevant instructions correctly forwarded
#' ## -----------------------------------------------------------------------
#' # The internal helper converts FALSE to NULL so that downstream JavaScript
#' # receives a consistent value (null rather than false).
#' m = addGeoArrowScatterplotLayer(
#'   map = dummy_map
#'   , url = "https://example.com/data.parquet"
#'   , layer_id = "my-layer-id"
#'   , geom_column_name = "geom"
#'   , popup = FALSE
#'   , tooltip = FALSE
#'   , js_code = "function(){}"
#'   , customProp  = "hello"   # passed via ...
#' )
#'
#' arg_list = m$jsHooks$render[[1]]$data
#'
#' ## -----------------------------------------------------------------------
#' ## 3.1. popup, tooltip FALSE become NULL
#' ## -----------------------------------------------------------------------
#' expect_null(
#'   arg_list[["popup"]]
#'   , info = "FALSE popup should become NULL"
#' )
#' expect_null(
#'   arg_list[["tooltip"]]
#'   , info = "FALSE tooltip should become NULL"
#' )
#'
#' ## -----------------------------------------------------------------------
#' ## 3.2. layer_id and geom_column_name are forwarded to the data list
#' ## -----------------------------------------------------------------------
#'
#' expect_equal(arg_list[["layerId"]], "my-layer-id")
#' expect_equal(arg_list[["geom_column_name"]], "geom")
#'
#' ## -----------------------------------------------------------------------
#' ## 3.3. map_class is forwarded correctly
#' ## -----------------------------------------------------------------------
#'
#' expect_equal(arg_list[["map_class"]], "maplibregl")
#'
#' ## -----------------------------------------------------------------------
#' ## 3.4. Extra dots are merged into the data list (modifyList behaviour)
#' ## -----------------------------------------------------------------------
#'
#' expect_equal(
#'   arg_list[["customProp"]]
#'   , "hello"
#'   , info = "dot args must survive modifyList into the data list"
#' )
#'
#' @export
addGeoArrowScatterplotLayer = function(
    map
    , data
    , source
    , file
    , url
    , layer_id = "scatter"
    , geom_column_name = "geometry"
    , popup = NULL
    , tooltip = NULL
    , render_options = renderOptions()
    , data_accessors = dataAccessors()
    , popup_options = popupOptions()
    , tooltip_options = tooltipOptions()
    , ...
) {

  UseMethod("addGeoArrowScatterplotLayer")

}


.addGeoArrowScatterplotLayer = function(
    map
    , data
    , source
    , file
    , url
    , layer_id = "scatter"
    , geom_column_name = "geometry"
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
        name = "deckglgeoarrowScatterplot"
        , version = "0.0.1"
        , src = system.file("htmlwidgets", package = "deckglgeoarrow")
        , script = list(
          src = "addGeoArrowDeckglScatterplotLayer.js"
          # , type = "module"
        )
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
      'function(el, x, data) {
        map = this.getMap();
        addGeoArrowDeckglScatterplotLayer(map, data);
      }'
    )
  }

  if (isFALSE(popup)) {
    popup = NULL
  }

  if (isFALSE(tooltip)) {
    tooltip = NULL
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
addGeoArrowScatterplotLayer.maplibregl = function(
    map
    , ...
) {
  .addGeoArrowScatterplotLayer(
    map
    , ...
    , map_class = "maplibregl"
  )
}

#' @export
addGeoArrowScatterplotLayer.mapboxgl = function(
    map
    , ...
  ) {
  .addGeoArrowScatterplotLayer(
    map
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
