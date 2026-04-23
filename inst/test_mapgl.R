library(mapgl)
library(geoarrowDeckglLayers)
library(geoarrow)
library(sf)
library(colourvalues)


### points =========================
n = 5e3
dat = data.frame(
  id = 1:n
  , x = runif(n, -180, 180)
  , y = runif(n, -60, 60)
)
dat = st_as_sf(
  dat
  , coords = c("x", "y")
  , crs = 4326
)
dat$fillColor = sample(hcl.colors(n, alpha = sample(seq(0, 1, length.out = n))))
dat$lineColor = sample(
  hcl.colors(n, alpha = sample(seq(0, 1, length.out = n)), palette = "inferno")
)
dat$radius = sample.int(15, nrow(dat), replace = TRUE)
dat$lineWidth = sample.int(5, nrow(dat), replace = TRUE)

options(viewer = NULL)

m = maplibre(
  style = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json'
  # , renderWorldCopies = FALSE
  )
  # geoarrowDeckglLayers:::add_globe_control()

# m = mapboxgl(
#   style = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json'
#   , projection = "mercator"
#   ) |>
#   add_navigation_control(visualize_pitch = TRUE) |>
#   add_layers_control(collapsible = TRUE, layers = c("test"))

m |>
  addGeoArrowScatterplotLayer(
    data = dat
    , layer_id = "deck-layer-group-last"
    , geom_column_name = attr(dat, "sf_column")
    , render_options = renderOptions()
    , data_accessors = dataAccessors(
      getRadius = "radius"
      , getFillColor = "fillColor"
      , getLineWidth = "lineWidth"
      , getLineColor = "lineColor"
    )
    , parameters = list(
      depthCompare = "always"
      , cullMode = "back"
    )
    , popup = TRUE
    , popup_options = popupOptions(
      anchor = "bottom-right"
    )
    , tooltip = FALSE
    , tooltip_options = tooltipOptions(
      anchor = "top-left"
    )
    , interleaved = TRUE
  ) |>
  add_layers_control(
    collapsible = TRUE
    , layers = list("Deck layer" = "deck-layer-group-last")
  ) |>
  # set_projection("mercator") |>
  add_globe_control() |>
  add_navigation_control(visualize_pitch = TRUE)




### polygons ==================================
# dat = st_read("~/Downloads/data.gpkg")
dat = mapview::franconia
idx = sapply(dat, is.factor)
dat[idx] = NULL
dat$fillColor = color_values(
  rnorm(nrow(dat))
  , alpha = sample.int(255, nrow(dat), replace = TRUE)
)
dat$lineColor = color_values(
  rnorm(nrow(dat))
  , alpha = sample.int(255, nrow(dat), replace = TRUE)
  , palette = "inferno"
)
dat$elevation = sample.int(2000, nrow(dat), replace = TRUE)
dat$lineWidth = sample.int(150, nrow(dat), replace = TRUE)


options(viewer = NULL)

m = maplibre(style = 'https://tiles.openfreemap.org/styles/liberty') |>
  fit_bounds(unname(st_bbox(dat)), animate = FALSE)

# m = mapboxgl(
#   style = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json'
#   , projection = "mercator"
#   ) |>
#   add_navigation_control(visualize_pitch = TRUE) |>
#   add_layers_control(collapsible = TRUE, layers = c("test"))

m |>
  addGeoArrowPolygonLayer(
    data = dat
    , layer_id = "deck-layer-group-last"
    , geom_column_name = attr(dat, "sf_column")
    , render_options = renderOptions(
      extruded = TRUE
    )
    , data_accessors = dataAccessors(
      getFillColor = "fillColor"
      , getLineColor = "lineColor"
      , getLineWidth = 2 #"lineWidth"
      , getElevation = "elevation"
    )
    , popup = TRUE
  ) |>
  add_layers_control(
    collapsible = TRUE
    , layers = list("Deck layer" = "deck-layer-group-last")
  ) |>
  # set_projection("mercator") |>
  add_globe_control() |>
  add_navigation_control(visualize_pitch = TRUE)


### lines ======================================
# dat = st_read("~/Downloads/DLM_4000_GEWAESSER_20211015.gpkg", layer = "GEW_4100_FLIESSEND_L")
# dat = st_read("~/Downloads/rivers_africa.fgb")
dat = mapview::trails
idx = sapply(dat, is.factor)
dat[idx] = NULL
dat = st_transform(dat, crs = "EPSG:4326")
dat$lineColor = color_values(
  rnorm(nrow(dat))
  , alpha = sample.int(255, nrow(dat), replace = TRUE)
  , palette = "inferno"
)
dat$lineWidth = sample.int(1500, nrow(dat), replace = TRUE)


options(viewer = NULL)

m = maplibre(style = 'https://tiles.openfreemap.org/styles/liberty') |>
  fit_bounds(unname(st_bbox(dat)), animate = FALSE)

# m = mapboxgl(
#   style = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json'
#   , projection = "mercator"
#   ) |>
#   add_navigation_control(visualize_pitch = TRUE) |>
#   add_layers_control(collapsible = TRUE, layers = c("test"))

m |>
  addGeoArrowPathLayer(
    data = dat
    , layerId = "test"
    , geom_column_name = attr(dat, "sf_column")
    , render_options = geoarrowDeckgl:::renderOptions(
      widthUnits = "meters"
      , widthScale = 100
      , widthMaxPixels = 200
    )
    , data_accessors = geoarrowDeckgl:::dataAccessors(
      getWidth = "lineWidth"
      , getColor = "lineColor"
    )
    , popup = TRUE
    , tooltip = TRUE
    , parameters = list(
      ## FIXME: neither depthTest:false nor depthCompare:"always" work in globe
      depthTest = FALSE
      , depthCompare = "never"
      # , antialias = TRUE
      , cullMode = "back"
    )
  ) |>
  add_navigation_control(visualize_pitch = TRUE) |>
  add_globe_control() |>
  add_layers_control(collapsible = TRUE, layers = c("test"))



### point cloud =========================
n = 5e3
dat = data.frame(
  id = 1:n
  , x = runif(n, -180, 180)
  , y = runif(n, -60, 60)
  , z = runif(n, 1, 20000)
)
dat = st_as_sf(
  dat
  , coords = c("x", "y", "z")
  , crs = 4326
)
dat$fillColor = color_values(
  rnorm(nrow(dat))
  , alpha = sample.int(255, nrow(dat), replace = TRUE)
)
dat$lineColor = color_values(
  rnorm(nrow(dat))
  , alpha = sample.int(255, nrow(dat), replace = TRUE)
  , palette = "inferno"
)
dat$radius = sample.int(15, nrow(dat), replace = TRUE)
dat$lineWidth = sample.int(5, nrow(dat), replace = TRUE)

# dat = st_read("~/tappelhans/privat/emr/data/15 August 2025 at 1313.kmz") |>
#   st_cast("MULTIPOINT") |>
#   st_cast("POINT")

# attr(dat$geometry, which = "z_range") = c(
#   zmin = min(st_coordinates(dat)[, 3])
#   , zmax = max(st_coordinates(dat)[, 3])
# )

options(viewer = NULL)

m = maplibre(style = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json') |>
  add_navigation_control(visualize_pitch = TRUE) |>
  add_globe_control()

# m = mapboxgl(
#   style = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json'
#   , projection = "mercator"
#   ) |>
#   add_navigation_control(visualize_pitch = TRUE) |>
#   add_layers_control(collapsible = TRUE, layers = c("test"))

m |>
  geoarrowDeckgl:::addGeoArrowPointCloudLayer(
    data = dat
    , layerId = "test"
    , geom_column_name = attr(dat, "sf_column")
    , render_options = geoarrowDeckgl:::renderOptions()
    , data_accessors = geoarrowDeckgl:::dataAccessors(
      getRadius = "radius"
      , getFillColor = "fillColor"
      , getLineWidth = "lineWidth"
      , getLineColor = "lineColor"
    )
    , popup = TRUE
    , popup_options = geoarrowDeckgl:::popupOptions(anchor = "bottom-right")
    , tooltip = TRUE
    , tooltip_options = geoarrowDeckgl:::tooltipOptions(anchor = "top-left")
  ) |>
  add_layers_control(collapsible = TRUE, layers = c("test"))

