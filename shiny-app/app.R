library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
library(leaflet)

# Load the iris dataset
data_race = 
data_age = 
data_locality = 

ui <- page_sidebar(
  title = "Virginia HRI Dashboard",
  sidebar = sidebar(
    selectInput("County", "Select county:",
                choices = c("All", unique(as.character(data_locality$Incident.Locality))),
                selected = "All"),
    selectInput("Age", "Select age group:",
                choices = c("All", unique(as.character(data_age$Patiient.Age.Group))),
                selected = "All"),
    selectInput("Race", "Select racial group:",
                choices = c("All", unique(as.character(data_race$Race.Category))),
                selected = "All")
  ),
  
  layout_columns(
    card(
      card_header("Plot of "),
      card_body(
        plotOutput("scatterPlot")
      )
    ),
    card(
      card_header("Line Plot of HRI Incident by Age Group"),
      card_body(
        tableOutput("linePlot")
      )
    )
  ),
  
  layout_columns(
    card(
      card_header("Faceted Plot of HRI Incident by Race"),
      card_body(
        verbatimTextOutput("facetPlot")
      )
    ),
      )
    )

server <- function(input, output) {

  # Filtered dataset based on inputs
  filtered_data <- reactive({
    data = data_locality
    #data cleaning steps here
    return(data)
  })
  
  # Output 1: Scatterplot
  output$scatterPlot <- renderPlot({
    #plot here
  })
  
  # Output 2: Data Table
  output$dataTable <- renderPlot({
    #plot here
  })
  
  # Output 3: Summary Text
  output$summaryText <- renderPlot({
    #plot here})
}

shinyApp(ui = ui, server = server)
