library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
library(leaflet)
library(readr)
library(stringr)
library(forcats)
library(shinyWidgets)

# Load the dataset
data_pop <- read_csv("app-data/data_pop.csv")
data_pop_age <- read_csv("app-data/data_pop_age.csv")
data_locality <- read.csv("app-data/data_locality")
data_age <- read.csv("app-data/data_age")
data_race <- read.csv("app-data/pud-vdh-hri-ems-byrace")

ui <- page_fixed(
  title = "Virginia HRI Dashboard",
  layout_columns(
    col_widths = c(4, 8),
    card(
      card_header("County Selection"),
      pickerInput(
        inputId = "County",
        label = "Select county:",
        choices = c("All", unique(as.character(data_locality$Incident.Locality))),
        selected = "All",
        multiple = TRUE,
        options = list(
          `actions-box` = TRUE,       
          `live-search` = TRUE,      
          `size` = 10                
        )
      )
      
    ),
    card(
      card_header("Heat Map of Counties over Time"),
      plotOutput("heatPlot", height = "400px")
    )
  ),
  
  layout_columns(
    col_widths = c(4, 8),
    card(
      card_header("Age Group Selection"),
      selectInput("Age", "Select age group:",
                  choices = c("All", unique(as.character(data_age$Patient.Age.Group))),
                  selected = "All")
    ),
    card(
      card_header("Line Plot of HRI Incidents by Age Group"),
      plotOutput("linePlot", height = "400px")
    )
  ),
  
  layout_columns(
    col_widths = c(4, 8),
    card(
      card_header("Racial Group Selection"),
      selectInput("Race", "Select racial group:",
                  choices = c("All", unique(as.character(data_race$Race.Category))),
                  selected = "All")
    ),
    card(
      card_header("Faceted Plot of HRI Incidents by Race"),
      plotOutput("facetPlot", height = "400px")
    )
  )
)

server <- function(input, output) {
  
  final_locality <- reactive({
    data_clean <- data_locality %>%
      mutate(
        HRI.Incident.Count = as.numeric(ifelse(HRI.Incident.Count == "*", 2, HRI.Incident.Count)),
        Incident.Locality = str_to_title(Incident.Locality),
        Incident.Month = factor(Incident.Month, levels = 1:12, labels = month.name)
      ) %>%
      filter(!is.na(HRI.Incident.Count))
    
    data_pop_clean <- data_pop %>%
      rename(
        Locality = CountyName,
        Population = TotalEstimate
      ) %>%
      mutate(
        Locality = str_to_title(Locality),
        Population = as.numeric(Population)
      ) %>%
      group_by(Locality) %>%
      summarise(Population = sum(Population, na.rm = TRUE))
    
    df <- data_clean %>%
      left_join(data_pop_clean, by = c("Incident.Locality" = "Locality")) %>%
      mutate(Incidents.Per.100k = (HRI.Incident.Count / Population) * 100000)
    
    if (!("All" %in% input$County)) {
      df <- df %>% filter(Incident.Locality %in% input$County)
    }
    
    return(df)
  })
  
  
  age_data_filtered <- reactive({
    data_age_clean <- data_age %>%
      filter(!is.na(HRI.Incident.Count), Incident.Year <= 2023) %>%
      filter(Patient.Age.Group != "Unknown Age")
    
    pop_age_clean <- data_pop_age %>%
      filter(AGE_GROUP == "single-year", GEOGRAPHY_LEVEL == "State") %>%  
      mutate(
        AGE_VALUE = as.numeric(AGE_VALUE),
        ESTIMATE_YEAR = as.integer(ESTIMATE_YEAR),
        Age.Group = case_when(
          AGE_VALUE >= 0   & AGE_VALUE <= 4   ~ "0 to 4 years old",
          AGE_VALUE >= 5   & AGE_VALUE <= 12  ~ "5 to 12 years old",
          AGE_VALUE >= 13  & AGE_VALUE <= 17  ~ "13 to 17 years old",
          AGE_VALUE >= 18  & AGE_VALUE <= 24  ~ "18 to 24 years old",
          AGE_VALUE >= 25  & AGE_VALUE <= 64  ~ "25 to 64 years old",
          AGE_VALUE >= 65                     ~ "65+ years old"
        )
      ) %>%
      filter(!is.na(Age.Group), !is.na(ESTIMATE_YEAR)) %>%
      group_by(ESTIMATE_YEAR, Age.Group) %>%
      summarise(Total.Population = sum(ESTIMATE, na.rm = TRUE), .groups = "drop")
    
    data_age_merged <- data_age_clean %>%
      left_join(pop_age_clean, by = c("Patient.Age.Group" = "Age.Group", "Incident.Year" = "ESTIMATE_YEAR"))
    
    df <- data_age_merged %>%
      mutate(Incidents.Per.100k = (HRI.Incident.Count / Total.Population) * 100000)
    
    
    if (input$Age != "All") {
      df <- df %>% filter(Patient.Age.Group == input$Age)
    }
    
    df
  })
  
  race_data_filtered <- reactive({
    df <- data_race %>%
      mutate(
        HRI.Incident.Count = as.numeric(ifelse(HRI.Incident.Count == "*", 2, HRI.Incident.Count)),
        Incident.Year = as.integer(Incident.Year)
      ) %>%
      filter(Incident.Year <= 2024)
    
    if (input$Race != "All") {
      df <- df %>% filter(Race.Category == input$Race)
    }
    
    df
  })
  
  output$heatPlot <- renderPlot({
    data_top10 <- final_locality() %>%
      group_by(Incident.Locality) %>%
      summarise(total = sum(HRI.Incident.Count, na.rm = TRUE)) %>%
      slice_max(order_by = total, n = 10) %>%
      inner_join(final_locality(), by = "Incident.Locality")  # Corrected: was merged_data()
    
    ggplot(data_top10, aes(
      x = Incident.Month,
      y = fct_reorder(Incident.Locality, Incidents.Per.100k, .fun = sum),
      fill = Incidents.Per.100k
    )) +
      geom_tile(color = "white") +
      scale_fill_viridis_c(option = "plasma", name = "Incidents per 100k") +
      labs(
        title = "Top 10 Localities: HRI Incidents per 100k Population by Month",
        x = "Month",
        y = "Locality"
      ) +
      theme_classic(base_size = 12) + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  output$linePlot <- renderPlot({
    ggplot(age_data_filtered(), aes(x = Incident.Year, y = Incidents.Per.100k, color = Patient.Age.Group, group = Patient.Age.Group)) +
      geom_line(size = 1.2) +
      geom_point(size = 2) +
      labs(
        title = "Heat-Related EMS Incidents per 100,000 Population by Age Group",
        x = "Year",
        y = "Incidents per 100,000 people",
        color = "Age Group"
      ) +
      theme_classic()
    
  })
  
  output$facetPlot <- renderPlot({
    ggplot(race_data_filtered(), aes(
      Incident.Year,
      HRI.Incident.Count,
      color = Race.Category
    )) +
      geom_point(size = 0.5) +
      geom_line() +
      facet_wrap(~Race.Category, ncol = 4, scales = "free_y") +
      theme_classic() +
      labs(
        title = "HRI Incident Count by Race",
        x = "Year",
        y = "HRI Incident Count",
        caption = "Note: Varied Y scale"
      ) +
      theme(legend.position = "none")
  })
}

shinyApp(ui = ui, server = server)
