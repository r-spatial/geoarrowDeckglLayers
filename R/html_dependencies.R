## deck.gl js ==================================================================
deckglDependencies = function() {
  fldr = system.file("htmlwidgets/lib/deckgl", package = "geoarrowDeckglLayers")
  list(
    htmltools::htmlDependency(
      "deck.gl"
      , readLines(file.path(fldr, "version.txt"))
      , src = c(
        # href = "https://cdn.jsdelivr.net/npm/deck.gl@9.1.0"
        fldr
      )
      , script = "dist.min.js"
    )
  )
}

## data src ====================================================================
deckglDataAttachmentSrc = function(fn, layerId) {
  data_dir <- dirname(fn)
  data_file <- basename(fn)
  list(
    htmltools::htmlDependency(
      name = layerId,
      version = '0.0.1',
      src = c(file = data_dir),
      attachment = data_file
    )
  )
}

## arrow js ====================================================================
arrowDependencies = function() {
  fldr = system.file("htmlwidgets/lib/apache-arrow", package = "geoarrowDeckglLayers")
  list(
    htmltools::htmlDependency(
      "apache-arrow"
      , readLines(file.path(fldr, "version.txt"))
      , src = c(
        # href = "https://cdn.jsdelivr.net/npm/apache-arrow@16.1.0"
        fldr
      )
      , script = "Arrow.es2015.min.js"
    )
  )
}

## geoarrow deck.gl-layers js ==================================================
geoarrowDeckglLayersDependencies = function() {
  fldr = system.file("htmlwidgets/lib/deckgl-layers", package = "geoarrowDeckglLayers")
  list(
    htmltools::htmlDependency(
      "geoarrow-deckgl-layers"
      , readLines(file.path(fldr, "version.txt"))
      , src = c(
        # href = "https://cdn.jsdelivr.net/npm/@geoarrow/deck.gl-layers@0.3.0/dist"
        fldr
      )
      , script = "dist.umd.min.js"
    )
  )
}

## geoarrow js =================================================================
geoarrowjsDependencies = function() {
  fldr = system.file("htmlwidgets/lib/geoarrow-js", package = "geoarrowDeckglLayers")
  list(
    htmltools::htmlDependency(
      "geoarrow-js"
      , readLines(file.path(fldr, "version.txt"))
      , src = c(
        # href = "https://cdn.jsdelivr.net/npm/@geoarrow/geoarrow-js@0.3.1/dist"
        fldr
      )
      , script = "geoarrow.umd.min.js"
    )
  )
}

## helpers js ==================================================================
helpersDependency = function() {
  list(
    htmltools::htmlDependency(
      "geoarrowDeckglHelpers"
      , '0.0.1'
      , src = system.file("htmlwidgets", package = "geoarrowDeckglLayers")
      , script = "geoArrowDeckglHelpers.js"
    )
  )
}


## deck.gl js mapbox ===========================================================
deckglMapboxDependency = function() {
  fldr = system.file("htmlwidgets/lib/deckgl-mapbox", package = "geoarrowDeckglLayers")
  list(
    htmltools::htmlDependency(
      "deck.gl-mapbox-overlay"
      , readLines(file.path(fldr, "version.txt"))
      , src = c(
        # href = "https://cdn.jsdelivr.net/npm/@deck.gl/mapbox@9.1.0/dist/"
        fldr
      )
      , script = c("dist.min.js")
    )
  )
}
