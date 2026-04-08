#' Names and versions of external JavaScript libraries.
#'
#' Names and versions of the external JavaScript libraries used in
#' `geoarrowDeckglLayers`.
#'
#' See e.g. \url{https://cdn.jsdelivr.net/npm/deck.gl/package.json}
#' or \url{https://cdn.jsdelivr.net/npm/@geoarrow/deck.gl-layers/package.json}
#' for more details on the JavaScript depencencies.
#'
#' @returns
#'   A named character vector with the versions of the `Deck.gl`
#'   and `geoarrow-deckgl-layers` JavaScript libraries shipped with this package.
#'
#' @examples
#' extJSLibs()
#'
#' @tests tinytest
#' expect_length(extJSLibs(), 2)
#' expect_length(names(extJSLibs()), 2)
#'
#' @export
extJSLibs = function() {

  structure(
    c(
      geoarrowDeckglLayersDependencies()[[1]]$version
      , deckglDependencies()[[1]]$version
    )
    , names = c(
      geoarrowDeckglLayersDependencies()[[1]]$name
      , deckglDependencies()[[1]]$name
    )
  )

}
