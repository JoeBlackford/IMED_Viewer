library(shiny)

ui <- fluidPage(
  titlePanel("Hello"),
  p("Test")
)

server <- function(input, output, session){}

shinyApp(ui, server)