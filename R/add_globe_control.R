# #' Add a globe control to a [mapgl::maplibrdata:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAbElEQVR4Xs2RQQrAMAgEfZgf7W9LAguybljJpR3wEse5JOL3ZObDb4x1loDhHbBOFU6i2Ddnw2KNiXcdAXygJlwE8OFVBHDgKrLgSInN4WMe9iXiqIVsTMjH7z/GhNTEibOxQswcYIWYOR/zAjBJfiXh3jZ6AAAAAElFTkSuQmCCe()] map.
# #'
# #' @param map the [mapgl::maplibre()] map to add the control to.
# #' @param position the position on the map. NOT WORKING YET!
# #'
# #' @examples
# #' library(mapgl)
# #'
# #' maplibre() |>
# #'   add_globe_control()
# #'
# add_globe_control <- function(map, position = "top-right") {
#
#   if (inherits(map, "mapboxgl")) {
#     warning(
#       "globeControl not available for mapboxgl, ignoring call"
#       , call. = FALSE
#     )
#     invisible()
#   }
#
#   map$dependencies = c(
#     map$dependencies
#     , list(
#       htmltools::htmlDependency(
#         name = "globeControl"
#         , version = "0.0.1"
#         , src = system.file("htmlwidgets", package = "geoarrowDeckglLayers")
#         , script = "globeControl.js"
#       )
#     )
#   )
#
#   js_code = "function(el, x, data) {
#     map = this.getMap();
#
#     addGlobeControl(map, data.postion);
#
#     // as long as globe view is not fully supported by deckgl, disable dragRotate
#     disableDragRotate = function() {
#       if (map.getProjection().type === 'globe') {
#         map.dragRotate.disable();
#       }
#       if (map.getProjection().type === 'mercator') {
#         map.dragRotate.enable();
#
#       }
#     }
#
#     let glbbtn = document.getElementsByClassName('maplibregl-ctrl-globe')[0]
#     glbbtn.addEventListener('click', disableDragRotate);
#   }"
#
#   map = htmlwidgets::onRender(
#     map
#     , htmlwidgets::JS(js_code)
#     , data = list(
#       position = position
#     )
#   )
#
#   return(map)
# }
