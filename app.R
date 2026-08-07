library(shiny)
message("Loading globals...")
source("R/globals.R")
message("Globals loaded")

message("Loading UI...")
source("R/ui.R")
message("UI loaded")

message("Loading server...")
source("R/server.R")
message("Server loaded")

message("Starting Shiny...")

shinyApp(ui, server)


