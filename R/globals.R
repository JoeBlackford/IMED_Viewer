########################################################################
# LOAD THE PACKAGES
########################################################################

library("shiny")
library("leaflet")
library("leafem")
library("sf")
library("terra")
library("dplyr")
library("R6")
library("shinycssloaders")

########################################################################
# Raster catalogue
########################################################################

rasters <- read.csv(
  "data/config/rasters.csv",
  stringsAsFactors = FALSE
)

########################################################################
# Layer metadata
########################################################################

metadata <- read.csv(
  "data/config/metadata.csv",
  stringsAsFactors = FALSE
)

rasters <- dplyr::left_join(
  rasters,
  metadata,
  by = "filename"
)

########################################################################
# Raster cache
########################################################################

message("Loading rasters into memory...")

raster_cache <- setNames(
  lapply(
    rasters$filename,
    function(f) {
      
      terra::rast(
        file.path(
          "data",
          "cogs_3857",
          f
        )
      )
      
    }
  ),
  rasters$filename
)

message(length(raster_cache), " rasters loaded.")

########################################################################
# England Electoral Wards
########################################################################

wards <- sf::st_read(
  "data/boundaries/2021 Wards England.json",
  quiet = TRUE
)

if (is.na(sf::st_crs(wards))) {
  sf::st_crs(wards) <- 27700
}

wards <- sf::st_transform(
  wards,
  4326
)

########################################################################
# Gloucestershire Electoral Wards
########################################################################

glos_wards <- sf::st_read(
  "data/boundaries/2021 Wards Gloucestershire.json",
  quiet = TRUE
)

if (is.na(sf::st_crs(glos_wards))) {
  sf::st_crs(glos_wards) <- 27700
}

glos_wards <- sf::st_transform(
  glos_wards,
  4326
)

########################################################################
# Helper functions
########################################################################

source("R/helpers.R")