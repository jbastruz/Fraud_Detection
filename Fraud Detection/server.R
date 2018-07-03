library(h2o)
library(shiny)
library(plotly)
library(DT)
library(png)
library(tidyverse)

#setwd("C:/Users/jeanbaptiste.astruz/iCloudDrive/App DL")

options(shiny.maxRequestSize=200*1024^2) 

function(input, output){
  
  observeEvent(input$TEST,{inFile <- input$file
    
    if (is.null(inFile)){
      
      return(NULL)
      
    }
    else{
      
      withProgress(message = 'Calculation', value = 0, {
        # Number of times we'll go through the loop
        n <- 2
        
        incProgress(1/n, detail = paste("Load Data"))
        Sys.sleep(0.1)
        
        prostate_df <- read.csv(inFile$datapath, sep = input$sep)
        prostate_df$Class = as.factor(as.character(prostate_df$Class))
        
        incProgress(1/n, detail = paste("Data Loaded"))
        Sys.sleep(0.1)
        
      })
      
      output$out = renderDataTable(datatable(prostate_df, options = list(lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')), searching = FALSE)))
      output$summary = renderPrint(summary(prostate_df))
      output$ui <- renderUI({
        
              if (is.null(input$file)){
                
                return()
                
              }
              else{
                
                fluidRow(  h2("Observation", style = "color:SteelBlue"),
                           dataTableOutput('out'),
                           tags$hr(),
                           h2("Summary", style = "color:SteelBlue"),
                           verbatimTextOutput('summary'))
              }
            }
          )
    }
  })

  output$image1 = renderImage({
    filename = "www/Addactis.png"
    list(src = filename, weight = "25px", height = "25px")
  }, deleteFile = F)
  
  output$image2 = renderImage({
    filename = "www/Addactis2.png"
    list(src = filename, weight = "70px", height = "70px")
  }, deleteFile = F)
  
  observeEvent(input$calcul, {inFile <- input$file
  
    if (is.null(inFile)){
      
      return(NULL)
      
    }
    else{
      if(input$Label==""){
        
        return()
      }
      else{
        
        withProgress(message = 'Calculation', value = 0, {
          # Number of times we'll go through the loop
          n <- 5
          
          incProgress(1/n, detail = paste("Load Data"))
          Sys.sleep(0.1)
          
          localH2O = h2o.init()
          
          prostate_df <- read.csv(inFile$datapath, sep = input$sep)
          prostate_df$Class = as.factor(as.character(prostate_df$Class))
          
          test = as.h2o(prostate_df)
          
          response <- "Class"
          features <- setdiff(colnames(prostate_df), response)
          
          ##### Create a h2o frame #####
          
          incProgress(1/n, detail = paste("Load Autoencoder"))
          Sys.sleep(0.1)

          model_nn <- h2o.loadModel("model_nn\\model_nn")
          model_nn
          
          model_nn_2 <- h2o.loadModel("model_nn_2\\DeepLearning_model_R_1522827383346_53")
          model_nn_2
          
          incProgress(1/n, detail = paste("Calculation autoencoder"))
          Sys.sleep(0.1)
          
          ##### Create an autoencoder #####
          
          pred <- as.data.frame(h2o.predict(object = model_nn_2, newdata = test)) %>%
            mutate(actual = as.vector(test[, 32]))
          
          incProgress(1/n, detail = paste("Calculation performance"))
          
          output$print = renderPrint({
            
            pred %>%
            group_by(actual, predict) %>%
            summarise(n = n()) %>%
            mutate(freq = n / sum(n))
            
          })
          
          incProgress(1/n, detail = paste("Making plot"))
          
          
          output$Fraud = renderDataTable(datatable(as.data.frame(test)[pred$predict == 1,]))
          
          
          output$plotlyMissed = renderPlotly({
            
            plot_ly(pred[pred$predict==1 & pred$actual==1,], x= ~actual, type = "histogram", name = 'Spoted',
                      marker = list(color = 'rgb(158,202,225)',line = list(color = 'rgb(8,48,107)', width = 1.5))) %>%
            add_trace(data = pred[pred$predict==0 & pred$actual==1,], x = ~actual, name = 'Missed',
                      marker = list(color = 'SteelBlue', line = list(color = 'rgb(8,48,107)', width = 1.5))) %>%
            layout(yaxis = list(title = 'Nb observations'), barmode = 'stack', width = 400, xaxis = list(title = 'Fraud'))
            
          })
          
          output$plotlyMistake = renderPlotly({
            
            plot_ly(pred[pred$predict==0 & pred$actual==0,], x= ~actual, type = "histogram", name = 'No Fraud',
                    marker = list(color = 'rgb(158,202,225)',line = list(color = 'rgb(8,48,107)', width = 1.5))) %>%
              add_trace(data = pred[pred$predict==1 & pred$actual==0,], x = ~actual, name = 'Mistake',
                        marker = list(color = 'SteelBlue', line = list(color = 'rgb(8,48,107)', width = 1.5))) %>%
              layout(yaxis = list(title = 'Nb observations'), barmode = 'stack', width = 400, xaxis = list(title = 'No Fraud'))
            
          })
        })
      }
    }
  })
}