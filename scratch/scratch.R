#Alia
library(dplyr)
library(readr)
library(ggplot2)
library(tidyr)

data_race = read.csv("/Users/aliajamil/Desktop/r/hw6-homer/data/pud-vdh-hri-ems-byrace")
data_race = data_race %>% 
  mutate(HRI.Incident.Count = as.numeric(ifelse(HRI.Incident.Count == "*", 2, HRI.Incident.Count)),
         Incident.Year = as.integer(Incident.Year),
         HRI.Incident.Count = as.numeric(HRI.Incident.Count)) %>%
  arrange(Race.Category, Incident.Year)

ggplot(data = data_race, aes(Incident.Year, HRI.Incident.Count, color = Race.Category)) + 
  geom_point(size=0.5) + geom_line() +
  facet_wrap(~Race.Category, ncol = 2, scales = "free_y") +
  theme_classic() + labs(title = "HRI Incident Count by Race", x = "Year", y = "HRI Incident Count",
                         caption = "Note: Varied Y scale") +
  theme(legend.position = "none")


#Edits - Nina

library(tidyverse)
library(lubridate)



data_age<-read.csv("/Users/ninawubu/Documents/pud-vdh-hri-ems-byage")
data_clean <- data_age %>%
  mutate(HRI.Incident.Count = as.numeric(gsub("\\*", "",HRI.Incident.Count))) %>%
  filter(!is.na(HRI.Incident.Count)) %>% 
  filter(Incident.Year<= 2024)
ggplot(data_clean, aes(x = Incident.Year, y =HRI.Incident.Count, color = Patient.Age.Group, group = Patient.Age.Group)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Heat-Related EMS Incidents by Age Group Over Time",
    x = "Year",
    y = "Number of Incidents",
    color = "Age Group"
  ) +
  theme_classic()



data_locality <- read.csv("/Users/ninawubu/Documents/pud-vdh-hri-ems-bylocality")

data_clean <- data_locality %>%
  mutate(
    HRI.Incident.Count = as.numeric(ifelse(HRI.Incident.Count == "*", 2, HRI.Incident.Count)),
    Incident.Locality = str_to_title(Incident.Locality),
    Incident.Month = factor(Incident.Month, levels = 1:12, labels = month.name)
  ) %>%
  filter(!is.na(HRI.Incident.Count))

top_localities <- data_clean %>%
  group_by(Incident.Locality) %>%
  summarise(total = sum(HRI.Incident.Count)) %>%
  slice_max(order_by = total, n = 10) %>%
  pull(Incident.Locality)

data_top10 <- data_clean %>%
  filter(Incident.Locality %in% top_localities)

ggplot(data_top10, aes(x = Incident.Month, y = fct_reorder(Incident.Locality, HRI.Incident.Count, .fun = sum), fill = HRI.Incident.Count)) +
  geom_tile(color = "white") +
  scale_fill_viridis_c(option = "plasma", name = "Incident Count") +
  labs(
    title = "Top 10 Localities: Heat-Related EMS Incidents by Month",
    x = "Month",
    y = "Locality"
  ) +
  theme_classic(base_size = 12)



