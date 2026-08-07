library(terra)

input_dir  <- "data/cogs"
output_dir <- "data/cogs_3857"

dir.create(output_dir, showWarnings = FALSE)

files <- list.files(
  input_dir,
  pattern = "\\.tif$",
  full.names = TRUE
)

for (f in files) {
  
  cat("Processing:", basename(f), "\n")
  
  r <- rast(f)
  
  r3857 <- project(
    r,
    "EPSG:3857",
    method = if (grepl("Decile", basename(f), ignore.case = TRUE))
      "near"
    else
      "bilinear"
  )
  
  writeRaster(
    r3857,
    filename = file.path(output_dir, basename(f)),
    overwrite = TRUE,
    gdal = c(
      "TILED=YES",
      "COMPRESS=DEFLATE",
      "COPY_SRC_OVERVIEWS=YES"
    )
  )
  
}