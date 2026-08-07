library(shiny)
library(leaflet)

ui <- fluidPage(
  
  tags$head(
    
    tags$title("IMED Explorer"),
    
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "styles.css"
    )
    
  ),
  
  fluidRow(
    
    ####################################################################
    # Sidebar
    ####################################################################
    
    column(
      
      width = 4,
      
      selectInput(
        "layer",
        "Environmental Indicator",
        choices = split(
          rasters$display_name,
          rasters$theme
        )
      ),
      
      hr(),
      
      tabsetPanel(
        
        ##################################################################
        # Information
        ##################################################################
        
        tabPanel(
          
          "Information",
          
          htmlOutput("layer_information")
          
        ),
        
        ##################################################################
        # Map Adjustments
        ##################################################################
        
        tabPanel(
          
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
              NULL,
              min = 0,
              max = 100,
              value = 80
            ),
            
            hr(),
            
            h4("Boundary Overlays"),
            
            checkboxInput(
              "show_wards",
              "UK Electoral Wards",
              FALSE
            ),
            
            checkboxInput(
              "show_glos_wards",
              "Gloucestershire Electoral Wards",
              FALSE
            ),
            
            div(
              
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
        
        ##################################################################
        # About
        ##################################################################
        
        tabPanel(
          
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
    
    column(
      
      width = 8,
      
      leafletOutput(
        "map",
        height = "85vh"
      )
      
    )
    
  )
  
)