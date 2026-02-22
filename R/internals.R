writeGeoarrow = function(
    data
    , path = tempfile()
    , layerId
    , geom_column_name
    , interleaved = TRUE
) {

  dir.create(path)
  path = file.path(
    path
    , sprintf(
    "%s.arrow"
    , layerId
    )
  )

  data_stream = nanoarrow::as_nanoarrow_array_stream(
    dat
    , geometry_schema = geoarrow::infer_geoarrow_schema(
      dat
      , coord_type = ifelse(interleaved, "INTERLEAVED", "SEPARATE")
    )
  )

  nanoarrow::write_nanoarrow(data_stream, path)

  return(path)

}
