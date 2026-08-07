library(terra)

RasterManager <- R6::R6Class(
  
  "RasterManager",
  
  public = list(
    
    rasters = NULL,
    
    current = NULL,
    
    initialize = function(catalogue){
      
      self$rasters <- catalogue
      
    },
    
    load = function(layer){
      
      row <- self$rasters[
        self$rasters$display_name == layer,
      ]
      
      filename <- file.path(
        "data",
        "cogs",
        row$filename
      )
      
      self$current <- terra::rast(filename)
      
      invisible(self$current)
      
    },
    
    metadata = function(){
      
      r <- self$current
      
      list(
        
        dimensions = dim(r),
        
        resolution = res(r),
        
        extent = ext(r),
        
        crs = crs(r),
        
        cells = ncell(r)
        
      )
      
    }
    
  )
  
)