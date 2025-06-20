#Alia exploring data
library(dplyr)
library(readr)
library(ggplot2)
library(tidyr)

data_race = read.csv("/Users/aliajamil/Desktop/r/hw6-homer/data/pud-vdh-hri-ems-byrace")
data_race = data_race %>% 
  mutate(across(HRI.Incident.Count, na_if, "*"))%>%
  drop_na() 

data_race = data_race %>%
  mutate(Incident.Year = as.integer(Incident.Year),
         HRI.Incident.Count = as.numeric(HRI.Incident.Count)) %>%
  arrange(Race.Category, Incident.Year)

ggplot(data = data_race, aes(Incident.Year, HRI.Incident.Count, color = Race.Category)) + 
  geom_point(size=0.5) + geom_line() +
  facet_wrap(~Race.Category, ncol = 2, scales = "free_y") +
  theme_classic() + labs(title = "HRI Incident Count by Race", x = "Year", y = "HRI Incident Count",
                         caption = "Note: Varied Y scale") +
  theme(legend.position = "none")



