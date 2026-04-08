# 2025-11-15 ====

## TEST WITH 2+ POLYGONS LAYERS ====

library(osmdata)
library(sf)

## get area of interest from osm
aoi = opq_osm_id (
  type = "relation"
  , id = 1152702
) |>
  opq_string () |>
  osmdata_sf () |> 
  getElement("osm_multipolygons")

aoi_utm = st_transform(
  aoi
  , crs = 25832L
)

## download parcels from wfs
cli = ows4R::WFSClient$new(
  "https://geo5.service24.rlp.de/wfs/alkis_rp.fcgi"
  , serviceVersion = "2.0.0"
)

parcels = cli$getFeatures(
  "ave:Flurstueck"
  , bbox = paste(
    st_bbox(aoi_utm)
    , collapse = ","
  )
) |> 
  st_transform(
    crs = 4326L
  )

## plot layers
options(viewer = NULL)

m = maplibre(
  style = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json'
) |>
  add_navigation_control(
    visualize_pitch = TRUE
  ) |>
  add_layers_control(
    collapsible = TRUE
    , layers = c(
      "aoi"
      , "parcels"
    )
  ) |>
  fit_bounds(
    unname(st_bbox(aoi))
    , animate = FALSE
  )

m |>
  geoarrowDeckgl:::addGeoArrowPolygonLayer(
    data = aoi
    , layerId = "aoi"
    , geom_column_name = attr(aoi, "sf_column")
    , render_options = geoarrowDeckgl:::renderOptions(
      extruded = FALSE
    )
    , data_accessors = geoarrowDeckgl:::dataAccessors(
      getFillColor = c(153, 142, 195, 128)
      , getLineColor = c(153, 142, 195, 128)
    )
    , popup = TRUE
  ) |>
  geoarrowDeckgl:::addGeoArrowPolygonLayer(
    data = parcels
    , layerId = "parcels"
    , geom_column_name = attr(parcels, "sf_column")
    , render_options = geoarrowDeckgl:::renderOptions(
      extruded = FALSE
    )
    , data_accessors = geoarrowDeckgl:::dataAccessors(
      getFillColor = c(241, 163, 64, 192)
      , getLineWidth = 1
    )
    , popup = TRUE
  )

