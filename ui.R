library(shinydashboard)
library(leaflet)
library(ggplot2)
library(DT)

header <- dashboardHeader(
  title = "DRIO-4103C",
  titleWidth = 250,
  dropdownMenu(type = "messages",
               messageItem(
                 from = "Vincent",
                 message = "Check out my git!",
                 href = "https://git.esiee.fr/barbosav"
               ),
               messageItem(
                 from = "Vincent",
                 message = "Check out this course!",
                 href = "https://perso.esiee.fr/~courivad/R/"
               ),
               messageItem(
                 from = "New User",
                 message = "How do I register?",
                 icon = icon("question"),
                 time = "14:45"
               )
  ), # end dropdownMenu
  
  dropdownMenu(type = "notifications",
               notificationItem(
                 text = "Check out datacamp!",
                 href = "http://www.datacamp.com",
                 icon("users")
               ),
               notificationItem(
                 text = "Fresh code delivered",
                 icon("truck"),
                 status = "success"
               ),
               notificationItem(
                 text = "Server load at 86%",
                 icon = icon("exclamation-triangle"),
                 status = "warning"
               )
  ), # end dropdownMenu
  
  dropdownMenu(type = "tasks",
               taskItem(value = 85, color = "yellow", text = "Progression of this dashboard:"),
               #taskItem(value = 17, color = "aqua", text = "Project X"),
               taskItem(value = 88, color = "red", text = "Overall project"),
               taskItem(value = 90, color = "green", text = "Documentation")
  ) # end dropdownMenu
) # end dashboardHeader

### DASHBOARD SIDEBAR
#####################

sidebar <- dashboardSidebar(
  width = 250,
  
  sidebarSearchForm(textId = "searchText", buttonId = "searchButton", label = "Search..."),
  
  sidebarMenu(
    menuItem("Introduction", tabName = "introduction"),
    menuItem("Data", tabName = "data", icon = icon("dashboard")),
    menuItem("Leaflet",
             tabName = "leaflet",
             icon = icon("map"),
             badgeLabel = "new",
             badgeColor = "green"
    ),
    menuItem("Charts", icon = icon("bar-chart-o"), startExpanded = TRUE,
             menuSubItem("Wordcloud", tabName = "charts_wordcloud"),
             menuSubItem("Histogram", tabName = "charts_hist")
    ),
    menuItem("Tools", tabName = "tools", icon = icon("th"))
  ) # end sidebarMenu
) # end dashboardSidebar

### DASHBOARD BODY
##################

body <- dashboardBody(
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
  
  tabItems(
    tabItem(tabName = "introduction",
            fluidRow(
              tags$div(class = "col-lg-12",
                       h1("Welcome to this dashboard"),
                       p("This is a case study on public transport in France.",
                         br(),
                         "After mastering the basics of R in class, we were asked
                to produce a dashboard including data analysis and vizualisations."
                       ),
                       p("This dashboard uses the shinydashboard library to make dashboards
                and Shiny which is an R package that makes it easy 
                to build interactive web apps straight from R. ")
              )
            ),
            
            fluidRow(
              
              column(width = 6, # Column 1
                     infoBox(
                       width = NULL,
                       title = "DATASETS",
                       subtitle = "https://opendata.stif.info"
                     )
              ),
              
              column(width = 6, # Column 2
                     infoBox(
                       width = NULL,
                       title = "DATASETS",
                       subtitle = "RATP, SNCF"
                     )
              )
            ),
            
            fluidRow( # row 1
              box(
                width = 12, # this box takes up the entire row, all 12 columns
                status = "warning", # primary success info warning danger
                title = "About this dashboard",
                p(strong("Author:"),"Vincent Barbosa Vaz", br(),
                  strong("Teacher:"),"Daniel Courivaud", br(),
                  strong("School:"),"ESIEE Paris")
              )
            )
            
            
            
            
            
            
    ),
    
    tabItem(tabName = "data", 
            fluidRow(
              column(width = 12,
                     tags$h1("Let's explore the datasets !"),
                     tags$p("This dashboards uses 2 main datasets :",
                            tags$ol(
                              tags$li("validations-sur-le-reseau-ferre-nombre-de-validations-par-jour-1er-sem.csv"),
                              tags$li("validations-sur-le-reseau-ferre-profils-horaires-par-jour-type-1er-sem.csv"),
                              tags$li("colors.csv")
                            ),
                            "Let's see what they contain."
                     )
              )
            ),
            fluidRow( column(width = 12,
              tags$h2("Main dataframe"),
              
              tags$strong("validations-sur-le-reseau-ferre-nombre-de-validations-par-jour-1er-sem.csv"),
              tags$br(),
              tags$strong("colors.csv"),
              tags$br(), tags$br())
              ),
            
            fluidRow(column(width = 12,
                            tags$p("This result is the merge of the first dataset and the third dataset (with some filtering and cleaning).")
            )),
            
            fluidRow(
              column(width = 12,
                     DT::dataTableOutput("table")
              )
            ),
            
            fluidRow(column(width = 12,
                            tags$br(),
                            tags$br(),
                            tags$p("The dataset colors.csv has been created from the RATP and SNCF colors station."),
                            tags$br(),
                            tags$img(src = "img/ratp_colors.png", width = "70%")
            ))
            
            
    ),
    
    tabItem(tabName = "tools",
            
            fluidRow(column(width = 12,
                            tags$h1("Miscellaneous section"),
                            tags$p("This section has no link to the project. It is intented to show the power
                                   of Shiny and a playground for developers."),
                            tags$br())
            ),
            
            fluidRow(column(width = 12,
            # slider
            sliderInput(
              inputId = "threshold",
              label = "Color threshold",
              min = 0,
              max = 100,
              value = 20
            )
            )),
            
            fluidRow(
              valueBox(
                value = 10,
                subtitle = "Fire",
                icon = icon(name="fire", lib="font-awesome")
              ),
              valueBox(
                value = 20,
                subtitle = "Star", 
                icon = icon("star")
              ),
              valueBoxOutput("us_box")
            ),
            
            # Boxes need to be put in a row (or column)
            fluidRow(
              box(plotOutput("plot1", height = 250)),
              
              box(
                title = "Controls",
                sliderInput("slider", "Number of observations:", 1, 100, 50)
              )
            )
            ,
            fluidRow(
              column(width = 12,
                     sliderInput("dynamic", "Dynamic", min = 1, max = 20, value = 10),
                     verbatimTextOutput("dynamic_value")
              )
            ),
            fluidRow(column(width = 12,
            tabBox(
              title = "My first box",
              tabPanel("Tab1", "Content for the first tab"),
              tabPanel("Tab2", "Content for the second tab")
            )))
            
    ), # end tabItem "tools"
    
    tabItem(tabName = "leaflet",
            
            fluidRow(column(width = 12,
                            tags$h1("Interactive map"),
                            tags$p("This is a geographic vizualisation of the stations. Stations are
                                   represented by dots and their size increase with the number of validations."),
                            tags$br(),
                            leafletOutput("plot"),
                            tags$br()
            )),
            fluidRow(column(width = 6,
                            selectInput('in2', 'Transport network', c(Choose='', as.character(unique_RESEAU)), selectize=FALSE)
                            #verbatimTextOutput('out2')
            ), 
            column(width = 6,
                   selectInput('in1', 'Line', c(Choose='', as.character(unique_RES_COM)), selectize=FALSE)
                   #verbatimTextOutput('out1')
            )),
            
            fluidRow(column(width = 12,
                            tags$br(),
                            tags$p("Select the day of analysis. Click Play button to animate the map 
                                   (there is a flashing map issue)."),
                            tags$br()
                            )),
            
            fluidRow(column(width = 6,
                            uiOutput("ui2")
            ), 
            column(width = 6,
                   uiOutput("ui")
            ))
    ),
    tabItem(tabName = "charts_wordcloud",
            fluidRow(column(width = 12,
            h1("Wordcloud"),
            plotOutput("plot2"),
            hr(),
            sliderInput("in_wordcloud_minfreq",
                        "Minimum Frequency:",
                        min = 1,  max = 10000000, value = 15),
            sliderInput("in_wordcloud_max",
                        "Maximum Number of Words:",
                        min = 1,  max = 30,  value = 10)
            ))
    ),
    tabItem(tabName = "charts_hist",
            fluidRow(column(width = 12,
                            h1("Histogram"),
                            tags$p("Histogram of the number of validations for a specific station."),
                            plotOutput("plot3"),
                            br()
            )),
            
            fluidRow(column(width = 6,
                            selectInput('in3', 'Station', c(Choose='', as.character(unique_NOMLONG)), selectize=FALSE)
            ), 
            column(width = 6,
                   sliderInput("in_hist",
                               "Breaks:",
                               min = 1,  max = 30,  value = 10)
            ))
    )
    
  ), # end tabItems
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  )
) # end dashboardBody

ui <- dashboardPage(
  skin = "blue",
  header,
  sidebar,
  body
)