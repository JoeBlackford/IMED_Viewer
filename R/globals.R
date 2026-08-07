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
# Helper functions
########################################################################

source("R/helpers.R")