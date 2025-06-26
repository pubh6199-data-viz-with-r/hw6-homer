[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/2V1dzZDL)
# Final Project: Virginia HRI Dashboard

Authors: Alia Jamil and Nina Wubu
Course: PUBH 6199 – Visualizing Data with R  
Date: 2025-06-26

## 🔍 Project Overview

Our topic is extreme heat and the effect on public health. We will look at incidence of heat-related illness through emergency department visits over time and by region of the United States to assess public health risk by demographic group. 


## 📊 Final Write-up

The final write-up, including code and interpretation of the visualizations, is available in the index.html.

## 📂 Repository Structure

```plaintext
.
├── _quarto.yml          # Quarto configuration file
├── .gitignore           # Files to ignore in git
├── data/                # Cleaned data files used in project
├── .Rproj               # RStudio project file
├── index.qmd            # Main Quarto file for final write-up
├── scratch/             # Scratch files for exploratory analysis         
├── shiny-app/           # Shiny app folder (if used)
│   ├── app.R
|   ├── www/             # Static files for Shiny app (CSS, JS, images)
│   └── app-data/        # Data files for Shiny app
├── docs/                # Rendered site (auto-generated)
└── README.md            # This file
```

## 🛠 How to Run the Code

### To render the write-up:

1. Open the `.Rproj` file in RStudio.
2. Open `index.qmd`.
3. Click **Render**. The updated html will be saved in the `docs/` folder.

### To run the Shiny app (if applicable):

```r
shiny::runApp("shiny-app")
```

> ⚠️ Make sure any necessary data files are in `shiny-app/app-data/`.

## 🔗 Shiny App Link

If your project includes a Shiny app, you can access it here:

👉 [shiny dashboard](https://ajamil.shinyapps.io/final-project/)

## 📦 Packages Used

- `tidyverse`
- `ggplot2`
- `quarto`
- `shiny` (if applicable)

## ✅ To-Do or Known Issues

Title missing in app.
