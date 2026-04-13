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
#' Currently, the following options are automatically set to he following defaults:
#'
#' * radiusUnits = "pixels" (ScatterplotLayer)
#' * radiusScale = 1 (ScatterplotLayer)
#' * lineWidthUnits = "pixels" (ScatterplotLayer, PolygonLayer)
#' * lineWidthScale = 1 (ScatterplotLayer, PolygonLayer)
#' * stroked = TRUE (ScatterplotLayer, PolygonLayer)
#' * filled = TRUE (ScatterplotLayer, PolygonLayer)
#' * radiusMinPixels = 3 (ScatterplotLayer)
#' * radiusMaxPixels = 15 (ScatterplotLayer)
#' * lineWidthMinPixels = 0 (ScatterplotLayer, PolygonLayer)
#' * lineWidthMaxPixels = 15 (ScatterplotLayer, PolygonLayer)
#' * billboard = FALSE (ScatterplotLayer, PathLayer)
#' * antialiasing = FALSE (ScatterplotLayer)
#' * extruded = FALSE (PolygonLayer)
#' * wireframe = TRUE (PolygonLayer)
#' * elevationScale = 1 (PolygonLayer)
#' * lineJointRounded = FALSE (PolygonLayer)
#' * lineMiterLimit = 4 (PolygonLayer)
#' * widthUnits = "pixels" (PathLayer)
#' * widthScale = 1 (PathLayer)
#' * widthMinPixels = 1 (PathLayer)
#' * widthMaxPixels = 5 (PathLayer)
#' * capRounded = TRUE (PathLayer)
#' * jointRounded = FALSE (PathLayer)
#' * miterLimit = 4 (PathLayer)
#' * beforeId = NULL (all Layer types)
#'
#' @return list with named options, possibly modified via `...` argument.
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
  )

  dot_lst = list(...)

  utils::modifyList(default_lst, dot_lst)
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
#' * getFillColor = c(0, 0, 0, 130) (ScatterplotLayer, PolygonLayer)
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

  default_lst = list(
    getRadius = 1
    , getColor = c(0, 0, 0, 255)
    , getFillColor = c(0, 0, 0, 130)
    , getLineColor = c(0, 0, 0, 255)
    , getLineWidth = 1
    , getElevation = 1000
    , getWidth = 1
  )

  dot_lst = list(...)

  utils::modifyList(default_lst, dot_lst)
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
#' * className = ""
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
#' * className = "geoarrow-deckgl-tooltip"
#' * closeButton = FALSE
#' * closeOnClick = FALSE
#' * closeOnMove = FALSE
#' * focusAfterOpen = TRUE
#' * maxWidth = "none"
#' * offset = 0
#' * subpixelPositioning = FALSE
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
    , className = "geoarrow-deckgl-popup"
    , closeButton = TRUE
    , closeOnClick = FALSE
    , closeOnMove = FALSE
    , focusAfterOpen = TRUE
    , maxWidth = "none"
    , offset = 0
    , subpixelPositioning = FALSE
  )

  dot_lst = list(...)

  utils::modifyList(default_lst, dot_lst)
}

#' @describeIn popupOptions options for tooltips
#'
#' @export
tooltipOptions = function(...) {

  default_lst = list(
    anchor = "top-left"
    , className = "geoarrow-deckgl-tooltip"
    , closeButton = FALSE
    , closeOnClick = FALSE
    , closeOnMove = FALSE
    , focusAfterOpen = TRUE
    , maxWidth = "none"
    , offset = 0
    , subpixelPositioning = FALSE
  )

  dot_lst = list(...)

  utils::modifyList(default_lst, dot_lst)
}
