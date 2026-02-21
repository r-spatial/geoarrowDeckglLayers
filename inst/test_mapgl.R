library(mapgl)
library(geoarrowDeckglLayers)
library(geoarrow)
library(sf)
library(colourvalues)


### points =========================
n = 1e4
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

options(viewer = NULL)

m = maplibre(
  style = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json'
  # , renderWorldCopies = FALSE
  ) |>
  set_projection("globe") |>
  add_navigation_control(visualize_pitch = TRUE) |>
  add_globe_control()

# m = mapboxgl(
#   style = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json'
#   , projection = "mercator"
#   ) |>
#   add_navigation_control(visualize_pitch = TRUE) |>
#   add_layers_control(collapsible = TRUE, layers = c("test"))

m |>
  geoarrowDeckgl:::addGeoArrowScatterplotLayer(
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
    , parameters = list(
      depthCompare = "always"
      # , antialias = TRUE
      , cullMode = "back"
    )
    , popup = TRUE
    , popup_options = geoarrowDeckgl:::popupOptions(anchor = "bottom-right")
    , tooltip = TRUE
    , tooltip_options = geoarrowDeckgl:::tooltipOptions(
      anchor = "top-left"
    )
  ) |>
  add_layers_control(collapsible = TRUE, layers = c("test"))




### polygons ==================================
dat = st_read("~/Downloads/data.gpkg")
dat$fillColor = color_values(
  rnorm(nrow(dat))
  , alpha = sample.int(255, nrow(dat), replace = TRUE)
)
dat$lineColor = color_values(
  rnorm(nrow(dat))
  , alpha = sample.int(255, nrow(dat), replace = TRUE)
  , palette = "inferno"
)
dat$elevation = sample.int(200, nrow(dat), replace = TRUE)
dat$lineWidth = sample.int(1500, nrow(dat), replace = TRUE)


options(viewer = NULL)

m = maplibre(style = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json') |>
  add_navigation_control(visualize_pitch = TRUE) |>
  add_layers_control(collapsible = TRUE, layers = c("test")) |>
  fit_bounds(unname(st_bbox(dat)), animate = FALSE)

# m = mapboxgl(
#   style = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json'
#   , projection = "mercator"
#   ) |>
#   add_navigation_control(visualize_pitch = TRUE) |>
#   add_layers_control(collapsible = TRUE, layers = c("test"))

m |>
  geoarrowDeckgl:::addGeoArrowPolygonLayer(
    data = dat
    , layerId = "test"
    , geom_column_name = attr(dat, "sf_column")
    , render_options = geoarrowDeckgl:::renderOptions(
      extruded = FALSE
    )
    , data_accessors = geoarrowDeckgl:::dataAccessors(
      getFillColor = "fillColor"
      , getLineColor = "lineColor"
      , getLineWidth = 1 # "lineWidth"
      , getElevation = "elevation"
    )
    , popup = TRUE
  )


### lines ======================================
# dat = st_read("~/Downloads/DLM_4000_GEWAESSER_20211015.gpkg", layer = "GEW_4100_FLIESSEND_L")
dat = st_read("~/Downloads/rivers_africa.fgb")
dat = st_transform(dat, crs = "EPSG:4326")
dat$lineColor = color_values(
  dat$Strahler
  , palette = "inferno"
)
dat$lineWidth = sample.int(1500, nrow(dat), replace = TRUE)


options(viewer = NULL)

m = maplibre(style = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json') |>
  add_navigation_control(visualize_pitch = TRUE) |>
  add_layers_control(collapsible = TRUE, layers = c("test"))

# m = mapboxgl(
#   style = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json'
#   , projection = "mercator"
#   ) |>
#   add_navigation_control(visualize_pitch = TRUE) |>
#   add_layers_control(collapsible = TRUE, layers = c("test"))

m |>
  geoarrowDeckgl:::addGeoArrowPathLayer(
    data = dat
    , layerId = "test"
    , geom_column_name = attr(dat, "sf_column")
    , render_options = geoarrowDeckgl:::renderOptions(
      widthUnits = "meters"
      , widthScale = 100
      , widthMaxPixels = 200
    )
    , data_accessors = geoarrowDeckgl:::dataAccessors(
      getWidth = "Strahler"
      , getColor = "lineColor"
    )
    , popup = TRUE
    , tooltip = TRUE
  )


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

