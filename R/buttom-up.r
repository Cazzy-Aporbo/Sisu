library(shiny)
library(tidyverse)
library(plotly)

# 1. Start with the smallest unit: a single student's data
studentAlice <- tibble(
  name = "Alice",
  age = 25,
  baseScore = 88,
  club = "Math"
)

print(studentAlice)

# 2. Expand to multiple students (small dataset)
students <- tibble(
  name = c("Alice","Bob","Charlie","Diana","Evan"),
  age = c(25,30,22,28,35),
  baseScore = c(88,92,79,85,95),
  club = c("Math","Science","Art","Math","Science")
)

print(students)

# 3. Introduce dynamic progression (simulate 5 semesters)
students <- students %>%
  rowwise() %>%
  mutate(scores = list(baseScore + cumsum(runif(5, -2, 5)))) %>%
  ungroup() %>%
  mutate(semester = list(1:5)) %>%
  unnest(c(scores, semester))

print(students)

# 4. Build the basic Shiny UI with input filters
ui <- fluidPage(
  titlePanel("Bottom-Up Interactive Student Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("semesterSelect", "Select Semester", min = 1, max = 5, value = 1),
      selectInput("clubSelect", "Select Club", choices = unique(students$club),
                  selected = unique(students$club), multiple = TRUE)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Scatter Plot", plotlyOutput("scatterPlot")),
        tabPanel("Line Progression", plotlyOutput("linePlot")),
        tabPanel("Heatmap", plotlyOutput("heatmapPlot"))
      )
    )
  )
)

# 5. Build Shiny Server starting from filtered data
server <- function(input, output) {
  
  filteredData <- reactive({
    # Bottom layer: subset dataset based on input
    students %>%
      filter(semester == input$semesterSelect, club %in% input$clubSelect)
  })
  
  # Scatter plot
  output$scatterPlot <- renderPlotly({
    df <- filteredData()
    plot_ly(df, x = ~age, y = ~scores, color = ~club,
            text = ~paste("Name:", name, "<br>Score:", round(scores,1), "<br>Club:", club),
            type = 'scatter', mode = 'markers') %>%
      layout(title = paste("Semester", input$semesterSelect, "Scores by Age"))
  })
  
  # Line plot (progression over semesters)
  output$linePlot <- renderPlotly({
    df <- students %>% filter(club %in% input$clubSelect)
    p <- ggplot(df, aes(x = semester, y = scores, group = name, color = club)) +
      geom_line(size = 1.2) +
      geom_point(size = 3) +
      labs(title = "Student Score Progression Over Semesters", x = "Semester", y = "Score") +
      theme_minimal()
    ggplotly(p)
  })
  
  # Heatmap: cumulative view
  output$heatmapPlot <- renderPlotly({
    df <- students %>% filter(club %in% input$clubSelect) %>%
      pivot_wider(names_from = semester, values_from = scores) %>%
      pivot_longer(cols = -c(name, club), names_to = "semester", values_to = "score")
    
    plot_ly(df, x = ~semester, y = ~name, z = ~score, type = "heatmap",
            colors = colorRamp(c("yellow","red"))) %>%
      layout(title = "Score Heatmap Across Semesters")
  })
}

# 6. Run the Shiny App
shinyApp(ui = ui, server = server)