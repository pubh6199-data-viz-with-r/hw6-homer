library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
library(leaflet)

# Load the dataset
data_locality = read.csv("/Users/ninawubu/Documents/pud-vdh-hri-ems-bylocality")
data_age = "/Users/ninawubu/Documents/pud-vdh-hri-ems-byage"
data_race = read.csv("/Users/aliajamil/Desktop/r/hw6-homer/data/pud-vdh-hri-ems-byrace")

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
      card_header("Heat Map of Counties over Time"),
      card_body(
        plotOutput("heatPlot")
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

server <- function(input, output) 

  # Filtered dataset based on inputs
  filtered_data <- reactive({
    data_age <- data_age %>%
      mutate(HRI.Incident.Count = as.numeric(gsub("\\*", "",HRI.Incident.Count))) %>%
      filter(!is.na(HRI.Incident.Count)) %>% 
      filter(Incident.Year<= 2024)
    data_race = data_race %>% 
      mutate(HRI.Incident.Count = as.numeric(ifelse(HRI.Incident.Count == "*", 2, HRI.Incident.Count)),
             Incident.Year = as.integer(Incident.Year),
             HRI.Incident.Count = as.numeric(HRI.Incident.Count)) %>%
      arrange(Race.Category, Incident.Year)
    
    data = rbind(data_age, data_race)
    return(data)
  })
  
  # Output 1: Heat Map
  output$heatPlot <- renderPlot({
    #plot here
  })
  
  # Output 2: Line Plot
  output$linePlot <- renderPlot({
    #plot here
  })
  
  # Output 3: Faceted Plot
  output$facetPlot <- renderPlot({
    ggplot(data = data_race, aes(Incident.Year, HRI.Incident.Count, color = Race.Category)) + 
      geom_point(size=0.5) + geom_line() +
      facet_wrap(~Race.Category, ncol = 2, scales = "free_y") +
      theme_classic() + labs(title = "HRI Incident Count by Race", x = "Year", y = "HRI Incident Count",
                             caption = "Note: Varied Y scale") +
      theme(legend.position = "none")
    })

 
shinyApp(ui = ui, server = server)
