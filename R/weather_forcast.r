library(shiny)
library(tidyverse)
library(plotly)
library(forecast)

# 1. Create a small sample weather dataset (bottom layer)
set.seed(123)
weather <- tibble(
  day = 1:30,
  temperature = round(rnorm(30, mean = 25, sd = 5),1), 
  humidity = round(runif(30, min = 40, max = 80),1)
)

print(weather)

# 2. Shiny UI
ui <- fluidPage(
  titlePanel("Interactive Weather Forecast Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("forecastDays", "Forecast Days", min = 1, max = 15, value = 7),
      checkboxInput("showHumidity", "Show Humidity", value = TRUE)
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Temperature Trend", plotlyOutput("tempPlot")),
        tabPanel("Forecasted Temperature", plotlyOutput("forecastPlot"))
      )
    )
  )
)

# 3. Shiny Server
server <- function(input, output) {
  
  # Reactive: forecast model
  forecastData <- reactive({
    tsTemp <- ts(weather$temperature, frequency = 7) # weekly seasonality
    model <- auto.arima(tsTemp)
    future <- forecast(model, h = input$forecastDays)
    tibble(day = (max(weather$day)+1):(max(weather$day)+input$forecastDays),
           temperature = as.numeric(future$mean))
  })
  
  # Temperature trend plot
  output$tempPlot <- renderPlotly({
    p <- ggplot(weather, aes(x = day, y = temperature)) +
      geom_line(color = "red", size = 1) +
      geom_point(color = "darkred", size = 2) +
      labs(title = "Observed Temperature Over Days", x = "Day", y = "Temperature (°C)") +
      theme_minimal()
    
    if(input$showHumidity){
      p <- p + geom_line(aes(y = humidity), color = "blue", linetype = "dashed") +
        labs(y = "Temperature / Humidity")
    }
    
    ggplotly(p)
  })
  
  # Forecast plot
  output$forecastPlot <- renderPlotly({
    forecastDf <- forecastData()
    plot_ly(forecastDf, x = ~day, y = ~temperature, type = 'scatter', mode = 'lines+markers',
            line = list(color = 'orange'), name = 'Forecasted Temp') %>%
      layout(title = "Forecasted Temperature",
             xaxis = list(title = "Day"),
             yaxis = list(title = "Temperature (°C)"))
  })
  
}

# 4. Run Shiny App
shinyApp(ui = ui, server = server)