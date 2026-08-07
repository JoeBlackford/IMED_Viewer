library(sf)
library(terra)
library(RColorBrewer)

bounds_to_extent <- function(bounds){
  
  req(bounds)
  
  # Create polygon from Leaflet bounds (WGS84)
  bbox <- st_as_sfc(
    st_bbox(
      c(
        xmin = bounds$west,
        xmax = bounds$east,
        ymin = bounds$south,
        ymax = bounds$north
      ),
      crs = 4326
    )
  )
  
  # Transform to British National Grid
  bbox_3857  <- st_transform(bbox, 3857)
  
  # Convert to terra extent
  terra::ext(terra::vect(bbox_3857))
  
}

get_palette <- function(palette_name, n = 11) {
  
  reverse <- grepl("_r$", palette_name)
  
  palette_name <- sub("_r$", "", palette_name)
  
  cols <- RColorBrewer::brewer.pal(n, palette_name)
  
  if (reverse) {
    cols <- rev(cols)
  }
  
  cols
}