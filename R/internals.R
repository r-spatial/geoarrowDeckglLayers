writeGeoarrow = function(
    data
    , path = tempfile()
    , layerId
    , suffix = "layer"
    , geom_column_name
    , interleaved = TRUE
) {

  dir.create(path)
  path = file.path(
    path
    , sprintf(
    "%s_%s.arrow"
    , layerId
    , suffix
    )
  )

  data_stream = nanoarrow::as_nanoarrow_array_stream(
    data
    , geometry_schema = geoarrow::infer_geoarrow_schema(
      data
      , coord_type = ifelse(interleaved, "INTERLEAVED", "SEPARATE")
    )
  )

  nanoarrow::write_nanoarrow(data_stream, path)

  return(path)

}
