library(shiny)
library(shinydashboard)
library(leaflet)
library("wordcloud")
library(dplyr) # data manipulation and pipe operator (%>%)
library(ggplot2)


server <- function(input, output) {
  output$us_box <- renderValueBox({
    valueBox(
      value = n_us,
      subtitle = "Move the threshold slider !",
      icon = icon("globe"),
      color = if (n_us < input$threshold) {
        "blue"
      } else {
        "fuchsia"
      }
    )
  }
  )
  
  output$ui <- renderUI({
    
    sliderInput("speed", "Speed (less is faster)", min = 200, max = 1000, value = 500) })
  
  output$ui2 <- renderUI({
    sliderInput("day", "Day",
                min = min(unique_JOUR), max = max(unique_JOUR),
                value = min(unique_JOUR), animate = animationOptions(interval = input$speed))})
  
  output$plot <- renderLeaflet({
    
    if (is.null(input$day)){
      day <- min(unique_JOUR)
    }else{
      day <- input$day
    }
    
    df_leaflet <- df_sum_valid_day_station_norm_locations %>%
      #dplyr::filter(JOUR== as.character(input$day))
      dplyr::filter(JOUR== day)
    #dplyr::filter(JOUR== min(unique_JOUR))
    #df_leaflet <- df_leaflet
    
    if(input$in1 != ""){
      df_leaflet <-df_leaflet %>%
        dplyr::filter(RES_COM== as.character(input$in1))
    }
    if(input$in2 != ""){
      df_leaflet <- df_leaflet %>%
        dplyr::filter(RESEAU== as.character(input$in2))
    }
    
    #df_leaflet <- df_station_locations %>% filter(RES_COM== "RER A") %>% filter(RESEAU== "TRAIN")
    #df_leaflet <- NULL
    #df_leaflet <- data.frame(RES_COM=NA, LAT=NA, LNG=NA, GARES_ID=c(0), NOMLONG=c(0), INDICE_LIG=c(0), RESEAU=c(0), COLOR_HEX=c(0))
    
    if(nrow(df_leaflet) == 0){
      leaflet() %>%
        addTiles() %>%
        setView(lat=48.8534, lng=2.3488, zoom = 7)
    }
    else {
      
      map <- leaflet(data = df_leaflet) %>%
        #leaflet(data = df_leaflet, options = leafletOptions(zoomAnimation = FALSE)) %>%
        addTiles() %>%
        
        #addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R") %>%
        #addMarkers(lat=48.8420053473, lng=2.23888732579)
        addCircleMarkers(
          lat = ~LAT,
          lng = ~LNG,
          stroke = FALSE,
          fillOpacity = 0.8,
          #color = ifelse(df_station_locations$COLOR_HEX == "", "#AAAAAA", ~COLOR_HEX),
          color = ~COLOR_HEX,
          radius = ~NORM,
          label = ~as.character(NOMLONG),
          # popup = paste("NOMLONG:", df_sum_valid_sem_station_norm_locations$NOMLONG, "<br>",
          #               "GARES_ID:", df_sum_valid_sem_station_norm_locations$GARES_ID, "<br>",
          #               "RES_COM:", df_sum_valid_sem_station_norm_locations$RES_COM, "<br>",
          #               "Traffic:"),
          group = "Stations"
        )%>%
        addLegend(position = "topright", colors = csv_colors$COLOR_HEX, labels = csv_colors$RES_COM,
                  title = "Station lines",
                  #labFormat = labelFormat(prefix = "$"),
                  opacity = 1, group = "Stations"
        ) %>%
        addLayersControl(position = "topleft", overlayGroups = c("Stations")) #%>%
      #setView(lat=48.8534, lng=2.3488, zoom = 10)
      #mapOptions(zoomToLimits = "first")
      #tileOptions(opacity = 0.5)
      
      map <- map %>% mapOptions(zoomToLimits = 'first')
      
    }
    
    
    
  })
  
  output$out1 <- renderPrint(input$in1)
  output$out2 <- renderPrint(input$in2)
  
  
  
  
  # output$out6 <- reactive({df %>%
  #   dplyr::select(GARES_ID, NOMLONG, RES_COM, INDICE_LIG, RESEAU) %>%
  #   merge(df_colors, by = "RES_COM") %>%
  #   merge(df3, by = "GARES_ID") %>%
  #   dplyr::filter(RES_COM == input$in1)
  # })
  
  
  
  # markerrs <- df3 %>%
  #   dplyr::filter(GARES_ID %in% (dplyr::filter(df4, RES_COM == out1) %>% dplyr::select(GARES_ID))$GARES_ID)
  # 
  
  set.seed(122)
  histdata <- rnorm(500)
  
  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })
  
  
  output$plot2 <- renderPlot({
    wordcloud(words = abbreviate(as.character(df_sum_valid_sem_station$NOMLONG), 15), random.order=FALSE, rot.per=0.1, freq = df_sum_valid_sem_station$NB_VALD, min.freq = input$in_wordcloud_minfreq, max.words = input$in_wordcloud_max, vfont=c("sans serif","plain"), scale=c(2,0.5), colors=brewer.pal(8, "Dark2"))
  })
  
  output$plot3 <- renderPlot({
    df_plot3 <- df_sum_valid_day_station %>% dplyr::filter(NOMLONG == as.character(input$in3))
    if(nrow(df_plot3) > 0){
      hist(df_plot3$NB_VALD,
           main=paste("Histogram for station : ", input$in3), 
           xlab="Number of validations", 
           border="white", 
           col="gray",
           breaks= input$in_hist)
      }
    })
  
  output$dynamic_value <- renderPrint({
    str(input$dynamic)
  })
  
  # Filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data <- df_station_locations
    # if (input$man != "All") {
    #   data <- data[data$manufacturer == input$man,]
    # }
    # if (input$cyl != "All") {
    #   data <- data[data$cyl == input$cyl,]
    # }
    # if (input$trans != "All") {
    #   data <- data[data$trans == input$trans,]
    # }
    data
  }))
  
  
}