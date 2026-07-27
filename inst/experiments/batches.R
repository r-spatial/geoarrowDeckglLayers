library(mapgl)
library(deckglgeoarrow)
library(nanoarrow)
library(geoarrow)
library(sf)
library(colourvalues)

style_positron = "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json"

### points =========================
n = 20e6
pts = data.frame(
  id = 1:n
  , x = runif(n, -180, 180)
  , y = runif(n, -90, 90)
)
pts = st_as_sf(
  pts
  , coords = c("x", "y")
  , crs = 4326
)
#
# pts$fillColor = sample(hcl.colors(n, alpha = sample(seq(0, 1, length.out = n))))
# pts$lineColor = sample(
#   hcl.colors(n, alpha = sample(seq(0, 1, length.out = n)), palette = "inferno")
# )
# pts$radius = sample.int(15, nrow(pts), replace = TRUE)
# pts$lineWidth = sample.int(5, nrow(pts), replace = TRUE)

batch_size = 4e6
n_batches = (nrow(pts) / batch_size)

splt = rep(0:(n_batches - 1), each = batch_size)

batches = split(pts, splt)

# Create an array stream
data_stream = nanoarrow::basic_array_stream(
  batches = batches
)

# data_stream = as_nanoarrow_array_stream(pts)

options(viewer = NULL)

m = maplibre(style = style_positron)

m = m |>
  addGeoArrowScatterplotLayer(
    data = data_stream
    , layer_id = "scatter"
    , geom_column_name = "geometry"
    , render_options = renderOptions(
      zIndex = 1
      , beforeId = "water"
    )
    # , data_accessors = dataAccessors(
    #   getRadius = "radius"
    #   , getFillColor = "fillColor"
    #   , getLineWidth = "lineWidth"
    #   , getLineColor = "lineColor"
    # )
    # , popup = TRUE
    # , popup_options = popupOptions(
    #   anchor = "bottom-right"
    # )
    , tooltip = FALSE
  ) |>
  set_view(c(100, 30), 2) |>
  add_globe_control() |>
  add_navigation_control(visualize_pitch = TRUE) |>
  add_layers_control(
    collapsible = TRUE
    , layers = list(
      "Scatter Layer" = generateDeckglLayerId("scatter", beforeId = "water")
      # , "Polygon Layer" = generateDeckglLayerId("polygon")
      # , "Path Layer" = generateDeckglLayerId("path")
    )
  ) |>
  deckglgeoarrow:::addMouseCoordinates()


m
