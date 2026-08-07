server <- function(input, output, session){
  
  ####################################################################
  # Selected raster metadata
  ####################################################################
  
  current_info <- reactive({req(input$layer)
    info <- rasters[
      rasters$display_name == input$layer,,drop = FALSE]
    info$type <- tolower(info$type)
    info})

  ####################################################################
  # Layer information panel
  ####################################################################
  
  output$layer_information <- renderUI({
    
    info <- current_info()
    
    div(
      
      class = "metadata-card",
      
      h3(info$title),
      
      div(
        class = "metadata-subtitle",
        info$short_description
      ),
      
      hr(),
      
      div(
        class = "metadata-section",
        
        h4("Description"),
        
        p(info$methodology_summary)
        
      ),
      
      hr(),
      
      div(
        
        class = "metadata-section",
        
        h4("Layer Details"),
        
        tags$table(
          
          class = "metadata-table",
          
          tags$tr(
            tags$th("Theme"),
            tags$td(info$theme)
          ),
          
          tags$tr(
            tags$th("Domain"),
            tags$td(info$domain)
          ),
          
          tags$tr(
            tags$th("Indicator"),
            tags$td(info$indicator)
          ),
          tags$tr(
            tags$th("Resolution"),
            tags$td(info$resolution)
          ),
          
          tags$tr(
            tags$th("Source"),
            tags$td(info$source)
          ),
          
          tags$tr(
            tags$th("Publisher"),
            tags$td(info$publisher)
          ),
          
          tags$tr(
            tags$th("Publication"),
            tags$td(info$publication_date)
          ),
          
          tags$tr(
            tags$th("Version"),
            tags$td(info$version)
          )
          
        )
        
      ),
      
      hr(),
      
      div(
        
        class = "metadata-section",
        
        h4("Interpretation"),
        
        div(
          class = "interpretation-box",
          
          strong(info$higher_values_indicate)
          
        )
        
      )
      
    )
    
  })
  ########################################################################
  # Map status
  ########################################################################
  
  map_status <- reactiveVal("")
  
  output$map_status <- renderUI({
    
    req(nzchar(map_status()))
    
    div(
      style = "
      background:#e8f4fd;
      border-left:4px solid #1f4e79;
      padding:10px;
      margin-bottom:10px;
      border-radius:4px;
      font-weight:600;
    ",
      
      map_status()
      
    )
    
  })
  ####################################################################
  # Current raster (cached)
  ####################################################################
  
  current_raster <- reactive({
    
    info <- current_info()
    
    req(info$filename %in% names(raster_cache))
    
    raster_cache[[info$filename]]
    
  })
  ####################################################################
  # Current map extent
  ####################################################################
  
  current_extent <- reactive({
    
    cat("current_extent triggered\n")
    
    req(input$map_bounds)
    
    bounds_to_extent(input$map_bounds)
    
  })
  
  ####################################################################
  # Crop raster to current map view
  ####################################################################
  
  current_crop <- reactive({
    
    cat("current_crop triggered\n")
    
    r <- current_raster()
    
    e <- terra::intersect(
      terra::ext(r),
      current_extent()
    )
    
    req(!is.null(e))
    
    terra::crop(r, e)
    
  })
  
  ####################################################################
  # Reduce ONLY for browser display
  ####################################################################
  
  current_display_raster <- reactive({
    
    cat("current_display_raster triggered\n")
    r <- current_crop()
    info <- current_info()
    nc <- terra::ncell(r)
    if (nc < 500000) {
      return(r)}
    cat("Original raster NAs:", global(is.na(r), "sum", na.rm = FALSE)[1,1], "\n")
    if (info$type == "decile") {
      
      fact <- ceiling(sqrt(nc / 500000))
      
      return(
        terra::aggregate(
          r,
          fact = fact,
          fun = "modal",
          na.rm = TRUE
        )
      )
      
    }
    
    fact <- ceiling(sqrt(nc / 500000))
    
    terra::aggregate(
      r,
      fact = fact,
      fun = mean,
      na.rm = TRUE
    )
    
  })
  
  ####################################################################
  # Initial map
  ####################################################################
  
  output$map <- renderLeaflet({
    
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(
        lng = -2,
        lat = 53,
        zoom = 6
      )
    
  })
  
  ####################################################################
  # Update raster
  ####################################################################
  
  observe({
    
    cat("\n=============================\n")
    cat("Updating raster...\n")
    
    t0 <- Sys.time()
    
    req(input$map_bounds)

    info <- current_info()
    
    cat("Current info: ",
        round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 3),
        " sec\n")
    
    t1 <- Sys.time()
    
    r <- current_display_raster()
    
    cat("Current display raster: ",
        round(as.numeric(difftime(Sys.time(), t1, units = "secs")), 3),
        " sec\n")
    
    t2 <- Sys.time()
    
    vals <- terra::values(r, mat = FALSE)
    vals <- vals[!is.na(vals)]
    
    cat("Extract values: ",
        round(as.numeric(difftime(Sys.time(), t2, units = "secs")), 3),
        " sec\n")
    
    req(length(vals) > 0)
    
    t3 <- Sys.time()
    
    if (info$type == "decile") {
      
      cols <- get_palette(
        info$palette,
        10
      )
      
        pal <- colorFactor(
        palette = cols,
        domain = 1:10,
        ordered = TRUE,
        na.color = "transparent"
      )
      legend_values <- 1:10
      
    } else {
      
      pal <- colorNumeric(
        palette = get_palette(
          info$palette,
          11
        ),
        domain = vals,
        na.color = "transparent"
      )
      
      legend_values <- vals
      
    }
    
    cat("Palette: ",
        round(as.numeric(difftime(Sys.time(), t3, units = "secs")), 3),
        " sec\n")
    
    t4 <- Sys.time()
    leafletProxy("map") %>%
      clearImages() %>%
      clearControls() %>%
      addRasterImage(
        r,
        colors = pal,
        opacity = input$opacity / 100,
        project = FALSE,
        maxBytes = 50 * 1024 * 1024
      ) %>%
      addLegend(
        pal = pal,
        values = legend_values,
        title = info$display_name,
        opacity = 1
      )
    
    cat("Leaflet render: ",
        round(as.numeric(difftime(Sys.time(), t4, units = "secs")), 3),
        " sec\n")
    
    cat("TOTAL: ",
        round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 3),
        " sec\n")

  })
  
  ####################################################################
  # England Electoral Ward Overlay
  ####################################################################
  
  observe({
    
    proxy <- leafletProxy("map")
    
    proxy %>%
      clearGroup("wards")
    
    if (isTRUE(input$show_wards)) {
      
      proxy %>%
        addPolygons(
          data = wards,
          group = "wards",
          color = "#333333",
          weight = 1,
          opacity = 1,
          fill = FALSE,
          smoothFactor = 0,
          label = ~WD21NM,
          labelOptions = labelOptions(
            direction = "auto",
            textsize = "13px",
            style = list(
              "font-weight" = "bold",
              "padding" = "6px" )),
          highlightOptions = highlightOptions(
            weight = 3,
            color = "#0072B2",
            bringToFront = TRUE ))}})
  
  ####################################################################
  # Gloucestershire Electoral Ward Overlay
  ####################################################################
  
  observe({
    
    proxy <- leafletProxy("map")
    
    proxy %>%
      clearGroup("glos_wards")
    
    if (isTRUE(input$show_glos_wards)) {
      
      proxy %>%
        addPolygons(
          data = glos_wards,
          group = "glos_wards",
          color = "black",
          weight = 2,
          opacity = 1,
          fill = FALSE,
          smoothFactor = 0,
          label = ~WD21NM,
          labelOptions = labelOptions(
            direction = "auto",
            textsize = "13px",
            style = list(
              "font-weight" = "bold",
              "padding" = "6px"
            )
          ),
          highlightOptions = highlightOptions(
            weight = 4,
            color = "blue",
            bringToFront = TRUE
          )
        )
      
    }
    
  })
  
}