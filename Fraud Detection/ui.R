library(h2o)
library(shiny)
library(DT)
library(shinythemes)
library(png)
library(tidyverse)
library(plotly)

fluidPage(theme = shinytheme("spacelab"),
  
  headerPanel(
    list(HTML('<img src="Addactis2.png" width = "45px" height="45px"/>'), "CreditCard Fraud Detection"),
    windowTitle="Fraud Detection"
  ), 
  
  sidebarPanel(
      
    fileInput("file", "File input:",
              accept = c(
                        "text/csv",
                        "text/comma-separated-values,text/plain",
                        ".csv")
              ),
    radioButtons("sep", "Separator",
                 choices = c(Comma = ",",
                             Semicolon = ";",
                             Tab = "\t"),
                 selected = ","),
    actionButton('TEST', "View Data", class = "btn-primary"),
    tags$hr(weight = "50px"),
    textInput("Label", "Label to Study:"),
    actionButton("calcul", "Calculation", class = "btn-primary")
    
  ),
  
  mainPanel(

    navbarPage(
      
      imageOutput("image1"),
      tabPanel('DataSet',
               
               uiOutput("ui")
               
      ),
      tabPanel('Fraud Detected',
               
               dataTableOutput('Fraud')#verbatimTextOutput("print")
               
      ),
      tabPanel('Graph',
                 
                column(4, plotlyOutput("plotlyMissed")),
                column(4, plotlyOutput("plotlyMistake")),
                column(4, verbatimTextOutput("print"))
               
               
      )
    )
  )
)