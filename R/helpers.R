#' Deck.gl render options
#'
#' In deck.gl every layer type has a specific set of render options, see e.g.
#' those for [ScatterPlotLayer](https://deck.gl/docs/api-reference/layers/scatterplot-layer#render-options).
#' This function sets all defaults for all available layer functions in this
#' package.
#' Please refer to the relevant [deck.gl documentation](https://deck.gl/docs/api-reference/layers/)
#' for a more detailed description of the available layer functions.
#' See Details for a list of currently available options, their defaults and the
#' layer types they apply to.
#'
#' @param ... named options to be passed to the relevant deck.gl JavaScript Method.
#'
#' @details
#' Currently, the following options are automatically set to the following defaults:
#'
#' \strong{ScatterplotLayer}
#'
#' * radiusUnits = "pixels"
#' * radiusScale = 1
#' * lineWidthUnits = "pixels"
#' * lineWidthScale = 1
#' * stroked = TRUE
#' * filled = TRUE
#' * radiusMinPixels = 3
#' * radiusMaxPixels = 15
#' * lineWidthMinPixels = 0
#' * lineWidthMaxPixels = 15
#' * billboard = FALSE
#' * antialiasing = FALSE
#'
#' \strong{PathLayer}
#'
#' * widthUnits = "pixels"
#' * widthScale = 1
#' * widthMinPixels = 1
#' * widthMaxPixels = 5
#' * capRounded = TRUE
#' * jointRounded = FALSE
#' * miterLimit = 4
#' * billboard = FALSE
#'
#' \strong{PolygonLayer}
#'
#' * lineMiterLimit = 4
#' * extruded = FALSE
#' * wireframe = TRUE
#' * elevationScale = 1
#' * lineJointRounded = FALSE
#' * lineWidthUnits = "pixels"
#' * lineWidthScale = 1
#' * stroked = TRUE
#' * filled = TRUE
#' * lineWidthMinPixels = 0
#' * lineWidthMaxPixels = 15
#'
#' \strong{All layers}
#'
#' * beforeId = NULL
#' * zIndex = 1
#' * autoHighlight = FALSE - requires `pickable` to be TRUE
#' * highlightColor = c(0, 0, 128, 128) - only applicable if `autoHighlight` is TRUE
#'
#' `zIndex` can be used to set layers order if multiple layers are added to a map.
#' Higher values will be plotted on top of lower values.
#' It is ignored, if `beforeId` is supplied.
#'
#' @return List with named options, possibly modified via `...` argument.
#'
#' @examples
#' # default settings
#' renderOptions()
#'
#' # modify selected options
#' renderOptions(radiusUnits = "meters", radiusScale = 10)
#'
#'
#' @export
#'
renderOptions = function(...) {

  # infer the function that called renderOptions
  # syscall1 = deparse(sys.call(1))[1]
  # rgx = gregexpr("^.*?(?=\\()", syscall1, perl = TRUE)[[1]]
  # len = attr(rgx, "match.length")
  # call = substr(syscall1, 1, len)
  # splt = unlist(strsplit(call, ":"))
  # fun = splt[length(splt)]
  # print(fun)
  #
  # # TODO: switch defaults based on fun

  default_lst = list(
    radiusUnits = "pixels"
    , radiusScale = 1
    , lineWidthUnits = "pixels"
    , lineWidthScale = 1
    , stroked = TRUE
    , filled = TRUE
    , radiusMinPixels = 3
    , radiusMaxPixels = 15
    , lineWidthMinPixels = 0
    , lineWidthMaxPixels = 15
    , billboard = FALSE
    , antialiasing = FALSE
    , extruded = FALSE
    , wireframe = TRUE
    , elevationScale = 1
    , lineJointRounded = FALSE
    , lineMiterLimit = 4
    , widthUnits = "pixels"
    , widthScale = 1
    , widthMinPixels = 1
    , widthMaxPixels = 5
    , capRounded = TRUE
    , jointRounded = FALSE
    , miterLimit = 4
    , beforeId = NULL
    , zIndex = 1
    , autoHighlight = FALSE
    , highlightColor = c(0, 0, 128, 128)
  )

  dot_lst = list(...)

  utils::modifyList(default_lst, dot_lst, keep.null = TRUE)
}


#' Deck.gl data accessors
#'
#' In deck.gl every layer type has a specific set of data accessors, see e.g.
#' those for [ScatterPlotLayer](https://deck.gl/docs/api-reference/layers/scatterplot-layer#data-accessors).
#' This function sets all defaults for all available layer functions in this
#' package.
#'
#' Please refer to the relevant [deck.gl documentation](https://deck.gl/docs/api-reference/layers/)
#' for a more detailed description of the available layer functions.
#' See Details for a list of currently available accessors, their defaults and the
#' layer types they apply to.
#'
#' If you want to map a certain accessor to a data specific value, you will need to
#' add it to the data and provide the column name to the respective data accessor.
#'
#' @param ... named accessors to be passed to the relevant deck.gl JavaScript Method.
#'
#' @details
#' Currently, the following accessors are automatically set to he following defaults:
#'
#' * getRadius = 1 (ScatterplotLayer)
#' * getColor = c(0, 0, 0, 255) (ScatterplotLayer, PathLayer)
#' * getFillColor = c(0, 0, 0, 255) (ScatterplotLayer, PolygonLayer)
#' * getLineColor = c(0, 0, 0, 255) (ScatterplotLayer, PolygonLayer)
#' * getLineWidth = 1 (ScatterplotLayer, PolygonLayer)
#' * getElevation = 1000 (PolygonLayer)
#' * getWidth = 1 (PathLayer)
#'
#' NOTE:
#' * accessors `getPosition`, `getPath`, `getPolygon` are handled internally
#' and should not be set!
#' * all `get*Color` accessors will accept either a vector of rgb(a) integers (0-255)
#' or a hex color string (potentially also with alpha) - see examples.
#'
#' @return List with named accessors, possibly modified via `...` argument.
#'
#' @examples
#' # default accessors
#' dataAccessors()
#'
#' # modify selected accessors
#' dataAccessors(
#'   getFillColor = c(0, 0, 255, 130),
#'   getLineColor = "#ff00ffaa"
#' )
#'
#' @export
dataAccessors = function(...) {

  # we set all defaults to NULL, so deck.gl defaults are used and overhead on
  # JS side is minimised, resulting in insanely fast default renders!
  default_lst = list(
    getRadius = NULL # 1
    , getColor = NULL # c(0, 0, 0, 255)
    , getFillColor = NULL # c(0, 0, 0, 255)
    , getLineColor = NULL # c(0, 0, 0, 255)
    , getLineWidth = NULL # 1
    , getElevation = NULL # 1000
    , getWidth = NULL # 1
  )

  dot_lst = list(...)

  utils::modifyList(default_lst, dot_lst, keep.null = TRUE)
}

#' Options for popups and tooltips
#'
#' @param ... named options to be passed to the popups and tooltips of the map.
#' See [maplibregl PopupOptions](https://maplibre.org/maplibre-gl-js/docs/API/type-aliases/PopupOptions/)
#' for details and available options.
#'
#' @details
#' Both `popupOptions` and `tooltipOptions` are passed to the PopupOptions object
#' of the [maplibregl Popup](https://maplibre.org/maplibre-gl-js/docs/API/classes/Popup/)
#' constructor. See [maplibregl PopupOptions](https://maplibre.org/maplibre-gl-js/docs/API/type-aliases/PopupOptions/)
#' for details.
#'
#' The `popupOptions` and `tooltipOptions` in this package only differ in their
#' respective defaults. These are:
#'
#' For `popupOptions`
#'
#' * anchor = "bottom"
#' * className = "deckglgeoarrow-popup"
#' * closeButton = TRUE
#' * closeOnClick = TRUE
#' * closeOnMove = FALSE
#' * focusAfterOpen = TRUE
#' * maxWidth = "none"
#' * offset = 0
#' * subpixelPositioning = FALSE
#'
#' For `tooltipOptions`
#'
#' * anchor = "top-left"
#' * className = "deckglgeoarrow-tooltip"
#' * closeButton = FALSE
#' * closeOnClick = FALSE
#' * closeOnMove = FALSE
#' * focusAfterOpen = TRUE
#' * maxWidth = "none"
#' * offset = 0
#' * subpixelPositioning = FALSE
#'
#' @return List with named popup/tooltip options, possibly modified via `...` argument.
#'
#' @describeIn popupOptions options for popups
#'
#' @examples
#' # default
#' popupOptions()
#' tooltipOptions()
#'
#' # modify selected options
#' tooltipOptions(anchor = "bottom-right", className = "my-css-class-name")
#'
#' @export
popupOptions = function(...) {

  default_lst = list(
    anchor = "bottom"
    , className = "deckglgeoarrow-popup"
    , closeButton = TRUE
    , closeOnClick = FALSE
    , closeOnMove = FALSE
    , focusAfterOpen = TRUE
    , maxWidth = "none"
    , offset = 0
    , subpixelPositioning = FALSE
  )

  dot_lst = list(...)

  utils::modifyList(default_lst, dot_lst, keep.null = TRUE)
}

#' @describeIn popupOptions options for tooltips
#'
#' @export
tooltipOptions = function(...) {

  default_lst = list(
    anchor = "top-left"
    , className = "deckglgeoarrow-tooltip"
    , closeButton = FALSE
    , closeOnClick = FALSE
    , closeOnMove = FALSE
    , focusAfterOpen = TRUE
    , maxWidth = "none"
    , offset = 0
    , subpixelPositioning = FALSE
  )

  dot_lst = list(...)

  utils::modifyList(default_lst, dot_lst, keep.null = TRUE)
}

#' Generate proper internal layer IDs
#'
#' Deck.gl injects layers into maplibre's canvas if `interleaved = TRUE` (the
#' default in all layer functions provided here). To do so, it generates specific
#' layer IDs from the `layer_id` provided. This function generates these deck.gl
#' specific layer IDs on the R side, so they can be used in other controls, such
#' as \code{\link[mapgl]{add_layers_control}}.
#'
#' @param layer_id the layer id provided to the respective `addGeoArrowDeckgl*`
#' layer function used.
#' @param beforeId the `beforeId` used in the respective `addGeoArrowDeckgl*`
#' layer function used.
#'
#' @return Character vector of internally used layer IDs.
#'
#' @examples
#' generateDeckglLayerId("my_scatterplot_layer")
#' generateDeckglLayerId(beforeId = "water")
#'
#' @export
generateDeckglLayerId = function(layer_id, beforeId = NULL) {
  if (!is.null(beforeId)) {
    return(sprintf("deck-layer-group-before:%s", beforeId))
  }
  return(sprintf("deck-layer-group-slot:%s", layer_id))
}
