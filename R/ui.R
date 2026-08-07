library(bslib)

ui <- page_sidebar(
  
  title = "IMED Explorer",
  
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#005EB8"
  ),
  
  tags$head(
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "styles.css"
    )
  ),
  
  ####################################################################
  # Sidebar
  ####################################################################
  
  sidebar = sidebar(
    
    width = 550,
    
    ##################################################################
    # Indicator (always visible)
    ##################################################################
    
    selectInput(
      "layer",
      "Environmental Indicator",
      choices = split(
        rasters$display_name,
        rasters$theme
      )
    ),
    
    hr(),
    
    ##################################################################
    # Tabs
    ##################################################################
    
    navset_tab(
      
      ################################################################
      # Information
      ################################################################
      
      nav_panel(
        
        "Information",
        
        htmlOutput("layer_information")
        
      ),
      
      ################################################################
      # Map Adjustments
      ################################################################
      
      nav_panel(
        
        "Map Adjustments",
        
        div(
          
          class = "metadata-card",
          
          h3("Map Display"),
          
          p(
            "Adjust how environmental data are displayed and customise the map overlays."
          ),
          
          hr(),
          
          h4("Raster Opacity"),
          
          sliderInput(
            "opacity",
            label = NULL,
            min = 0,
            max = 100,
            value = 80
          ),
          
          hr(),
          
          h4("Boundary Overlays"),
          
          checkboxInput(
            "show_wards",
            "UK Electoral Wards",
            value = FALSE
          ),
          
          checkboxInput(
            "show_glos_wards",
            "Gloucestershire Electoral Wards",
            value = FALSE
          ),
          
          tags$div(
            
            class = "warning-box",
            
            h5("Performance"),
            
            p(
              "Changing indicators or enabling boundary overlays may take a few seconds while the map updates."
            ),
            
            hr(),
            
            h5("Display Resolution"),
            
            p(
              "When viewing England-wide maps, raster layers are displayed at a lower resolution to improve performance. As you zoom in, the map automatically displays more detailed data. The underlying data are not modified."
            )
            
          )
          
        )
        
      ),
      
      ################################################################
      # About
      ################################################################
      
      nav_panel(
        
        "About",
        
        div(
          
          class = "metadata-card",
          
          h3("IMED Explorer"),
          
          p(
            "Explore the Indices of Multiple Environmental Deprivation (IMED) for England using an interactive mapping application."
          ),
          
          hr(),
          
          h4("Data Source"),
          
          p("Natural England"),
          
          hr(),
          
          h4("Coverage"),
          
          p("England"),
          
          hr(),
          
          h4("Licence"),
          
          p("Open Government Licence v3.0"),
          
          hr(),
          
          h4("Application"),
          
          p(
            "Developed using R Shiny, Leaflet and Cloud Optimised GeoTIFFs to provide responsive visualisation of high-resolution environmental deprivation datasets."
          )
          
        )
        
      )
      
    )
    
  ),
  
  ####################################################################
  # Map
  ####################################################################
  
  layout_column_wrap(
    
    width = 1,
    
    card(
      
      full_screen = TRUE,
      
      leafletOutput(
        "map",
        height = "85vh"
      )
      
    )
    
  )
  
)